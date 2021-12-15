resource "aws_db_instance" "A4_final_db" {
    allocated_storage = var.db_allocated_storage
    storage_type = var.db_storage_type
    engine = var.db_engine
    engine_version = var.db_engine_ver
    instance_class = var.db_instance_type
    name = var.db_name
    identifier = var.db_identifier
    username = var.db_user
    password = var.db_passwd
    parameter_group_name = var.db_parameter_group_name
    availability_zone = "${var.region}${var.az[0]}"
    # multi_az = true
    db_subnet_group_name = aws_db_subnet_group.A4_dbsg.id
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    skip_final_snapshot = true
    tags = {
        "Name" = "a4-db"
    }
}

resource "aws_db_subnet_group" "A4_dbsg" {
    name = "a4-dbsg"
    subnet_ids = [aws_subnet.A4_pridb[0].id,aws_subnet.A4_pridb[1].id]
    tags = {
        "Name" = "a4-dbsg"
    }
}