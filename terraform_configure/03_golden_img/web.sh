#!/bin/bash
#!/bin/sh

useradd -aG wheel ec2-user

yum -y update
sudo amazon-linux-extras install nginx1 -y
systemctl enable nginx
service nginx start

yum install -y git
git clone https://github.com/dudgns3443/HealthCare.git
cp -rf HealthCare/* /usr/share/nginx/html/

# KST 시간
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# web_log
sudo -i
sudo cd /root
cat > /root/web_log.sh << EOF
# web_sys_log
sudo aws s3 cp /var/log/messages s3://bucket-log-kth/web_log/web_sys_log/"$(date "+%Y-%m-%d")".log

# web_error_log
sudo aws s3 cp /var/log/messages s3://bucket-log-kth/web_log/web_error_log/"$(date "+%Y-%m-%d")".log
EOF
mkdir aaa
sudo chmod 777 /root/web_log.sh
mkdir bbb
sudo echo "* * * * * root bash /root/web_log.sh" >> /etc/crontab
mkdir ccc