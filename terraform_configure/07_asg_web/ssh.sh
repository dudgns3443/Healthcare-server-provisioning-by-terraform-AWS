#!/bin/bash
usermod -aG wheel ec2-user

sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sed -i 's/# %wheel/%wheel/g' /etc/sudoers
echo "work" | passwd --stdin ec2-user

systemctl restart sshd

NLB_DNS=`aws elbv2 describe-load-balancers --names "a4-nlb" --query "LoadBalancers[*].DNSName[]" --output text --region=ap-northeast-2`

# KST 시간
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# web_log
sudo -i
cat > web_log.sh << EOF
# web_sys_log
sudo aws s3 cp /var/log/messages s3://bucket-log-kth/web_log/web_sys_log/$(date "+%Y-%m-%d").log

# web_error_log
sudo aws s3 cp /var/log/messages s3://bucket-log-kth/web_log/web_sys_log/$(date "+%Y-%m-%d").log
EOF

chmod 777 web_log.sh

echo "59 11 * * * root bash /root/web_log.sh" >> /etc/crontab





























wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
sudo mkdir /usr/share/collectd
sudo touch /usr/share/collectd/types.db 
sudo cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << EOF
                        {
                            "agent": {
                                    "metric_collection_interval": 60,
                                    "run_as_user": "root"
                            },
                            "logs": {
                                    "logs_collected": {
                                            "files": {
                                                    "collect_list": [
                                                            {
                                                                    "file_path": "/var/log/messages",
                                                                    "log_group_name": "was-log",
                                                                    "log_stream_name": "{instance_id}"
                                                            },
                                                            {
                                                                    "file_path": "/var/log/nginx/error.log",
                                                                    "log_group_name": "nginx_error",
                                                                    "log_stream_name": "{instance_id}"
                                                            }
                                                    ]
                                            }
                                    }

                            },
                            "metrics":{
                                    "namespace":"was",
                                    "append_dimensions": {
                                                            "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
                                                            "InstanceId": "${aws:InstanceId}",
                                                            "InstanceType": "${aws:InstanceType}"
                                    },
                                    "metrics_collected":{
                                            "collectd": {
                                                    "metrics_aggregation_interval": 60
                                                    },
                                            "cpu":{
                                                            "measurement":[
                                                                    "cpu_usage_idle",
                                                                    "cpu_usage_iowait",
                                                                    "cpu_usage_user",
                                                                    "cpu_usage_system"
                                                            ],
                                                            "metrics_collection_interval": 60,
                                                            "resources": ["*"],
                                                            "totalcpu": false
                                            },
                                            "disk":{
                                                            "measurement":[
                                                                    "used_percent",
                                                                    "disk_free",
                                                                    "disk_used_percent"
                                                            ],
                                                            "metrics_collection_interval": 60,
                                                            "resources": ["*"]
                                            },
                                            "diskio": {
                                                    "measurement": [
                                                            "io_time"
                                                            ],
                                                            "metrics_collection_interval": 60,
                                                            "resources": [
                                                                    "*"
                                                                    ]
                                                    },
                                                     "mem":{
                                                            "measurement":[
                                                                    "mem_used_percent",
                                                                    "mem_free"
                                                            ],
                                                            "metrics_collection_interval": 60
                                            },
                                            "statsd": {
                                                    "metrics_aggregation_interval": 60,
                                                    "metrics_collection_interval": 60,
                                                    "service_address": ":8125"
                                            },
                                            "swap": {
                                                    "measurement": [
                                                            "swap_used_percent"
                                                            ],
                                                            "metrics_collection_interval": 60
                                            }
                                    }
                            }
                        }
EOF
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
