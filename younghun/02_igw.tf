resource "aws_internet_gateway" "yhkim_ig" {
  vpc_id = aws_vpc.yhkim_vpc.id

  tags = {
    "Name" = "yth-ig"
  }
}

resource "aws_route_table" "yh_rf" {
  vpc_id = aws_vpc.yhkim_vpc.id
  
  route {
    cidr_block = "10.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yhkim_ig.id
  }
  
  tags = {
    "Name" = "yh-rt"
  }
}

resource "aws_route_table_association" "yh_rtas" {
  count = length(var.pub_cidr)
  subnet_id      = aws_subnet.yh_pub[count.index].id
  route_table_id = aws_route_table.yh_rf.id
}