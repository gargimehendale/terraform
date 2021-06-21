resource "aws_vpc" "myvpc" {
 cidr_block = var.new_cidr
 enable_dns_hostnames = true
 tags = {
 Name = "myvpc"
 }
}

data "aws_availability_zones" "zone_available" {
  state = "available"
}
resource "aws_subnet" "public_subnet"{
depends_on = [aws_vpc.myvpc]
availability_zone = element(data.aws_availability_zones.zone_available.names,count.index)
vpc_id = var.vpc_id
cidr_block = element(var.pub_cidr, count.index)
count = length(var.pub_cidr)
tags = {
Name = "public_Subnet${count.index+1}"
}
}

resource "aws_subnet" "private_subnet"{
depends_on = [aws_vpc.myvpc]
availability_zone = element(data.aws_availability_zones.zone_available.names,count.index)
vpc_id = aws_vpc.myvpc.id
cidr_block = element(var.priv_cidr, count.index)
count = length(var.priv_cidr)
tags = {
Name = "private_Subnet${count.index+1}"
}
}

/*####################  found private subnet id ##########################
data "aws_subnet_ids" "private_subnet_id"{
depends_on = [ aws_vpc.myvpc,aws_subnet.private_subnet ]
vpc_id = aws_vpc.myvpc.id
tags = {  Name = "*priv*"  }
}

####################  found public subnet id ##########################
data "aws_subnet_ids" "public_subnet_id"{
depends_on = [ aws_vpc.myvpc,aws_subnet.public_subnet ]
vpc_id = aws_vpc.myvpc.id
tags = {  Name = "*publ*"  }
}
*/

resource "aws_internet_gateway" "gateway" {
depends_on = [aws_vpc.myvpc,aws_subnet.private_subnet,aws_subnet.public_subnet]
vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "internet_gw"
  }
}


resource "aws_eip" "ip"{
vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
allocation_id = aws_eip.ip.id
subnet_id = element(aws_subnet.public_subnet.*.id,0)
tags = {
    Name = "NAT_gw"
  }
}

resource "aws_route_table" "rtable_public"{
vpc_id = aws_vpc.myvpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
tags = {
Name = "public-route-table"
}
}

resource "aws_route_table_association" "pub" {
count = length(aws_subnet.public_subnet)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.rtable_public.id
}

resource "aws_route_table" "rtable_private"{
vpc_id = aws_vpc.myvpc.id
route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
tags = {
Name = "private-route-table"
}
}

resource "aws_route_table_association" "priv" {
count = length(aws_subnet.private_subnet) 
subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.rtable_private.id
}

resource "aws_security_group" "sg_ec2"{
 name        = "sg_allow_ssh"
 description = "Allow inbound/outbound traffic to ec2"
 vpc_id      = aws_vpc.myvpc.id
 ingress {
    description      = "inbound rule"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
tags = {
Name = "ec2_sg"
}
}
resource "aws_security_group" "sg_rds"{
 name        = "sg_allow_rds"
 description = "Allow inbound/outbound traffic to rds"
 vpc_id      = aws_vpc.myvpc.id
depends_on = [aws_vpc.myvpc,aws_subnet.private_subnet,aws_subnet.public_subnet]
 ingress {
    description      = "inbound rule"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [aws_security_group.sg_ec2.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
tags = {
Name = "rds_sg"
}
}

