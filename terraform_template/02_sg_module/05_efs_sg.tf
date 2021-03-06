#EFS Security-Group
resource "aws_security_group" "a4_efs_sg" {
  vpc_id = data.terraform_remote_state.network.outputs.a4_vpc_web_id
  name = "EFS security group"
  description = "EFS-2049"
  tags = { "Name" = "efs-sg"}
}

#EFS Security-Group-Rule for EFS
resource "aws_security_group_rule" "efs_rule" {
  type = var.rule_type[0]
  from_port = var.port_efs
  to_port = var.port_efs
  protocol = var.protocol
  source_security_group_id = aws_security_group.a4_bastion_sg.id
  security_group_id = aws_security_group.a4_efs_sg.id
}

#EFS Security-Gruop-Rule egress
resource "aws_security_group_rule" "egress_efs" {
  type = var.rule_type[1]
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = [var.route_cidr_global]
  security_group_id = aws_security_group.a4_efs_sg.id
}