#AWS VPC creation#########################################################
resource "aws_vpc" "myvpc" {
 cidr_block = var.new_cidr
 enable_dns_hostnames = true
 tags = {
 Name = "myvpc"
 }
}

###########################  availibility zones  ####################
data "aws_availability_zones" "zone_available" {
  state = "available"
}
###########################    AWS Public subnet ####################
resource "aws_subnet" "public_subnet"{
depends_on = [aws_vpc.myvpc]
availability_zone = element(data.aws_availability_zones.zone_available.names,index(var.pub_cidr, each.value))
vpc_id = var.vpc_id
cidr_block = each.value
for_each = toset(var.pub_cidr)
tags = {
Name = "public_Subnet${index(var.pub_cidr, each.value) + 1}"
}
}

#################  AWS private subnet #############################
resource "aws_subnet" "private_subnet"{
depends_on = [aws_vpc.myvpc]
availability_zone = element(data.aws_availability_zones.zone_available.names,index(var.priv_cidr, each.value))
vpc_id = aws_vpc.myvpc.id
cidr_block = each.value
for_each = toset(var.priv_cidr)
tags = {
Name = "private_Subnet${index(var.priv_cidr, each.value) + 1}"
}
}

####################  found private subnet id ##########################
data "aws_subnet_ids" "private_subnet_id"{
depends_on = [ aws_vpc.myvpc,aws_subnet.private_subnet ]
vpc_id = aws_vpc.myvpc.id
tags = {  Name = "*private*"  }
}

####################  found public subnet id ##########################
data "aws_subnet_ids" "public_subnet_id"{
depends_on = [ aws_vpc.myvpc,aws_subnet.public_subnet ]
vpc_id = aws_vpc.myvpc.id
tags = {  Name = "*public*"  }
}


#############################   internet gateway #########################
resource "aws_internet_gateway" "gateway" {
depends_on = [aws_vpc.myvpc]
vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "internet_gw"
  }
}


#############################  elastic ip ###############################
resource "aws_eip" "ip"{
vpc = true
}

######################  NAT Gateway  ###################################
resource "aws_nat_gateway" "nat_gw" {
allocation_id = aws_eip.ip.id
subnet_id = element(tolist(data.aws_subnet_ids.public_subnet_id.ids),0)
tags = {
    Name = "NAT_gw"
  }
}

########################## public  route table ########################
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

########################### public route table association  ###############
resource "aws_route_table_association" "pub" {
  for_each = toset(var.pub_cidr)
  subnet_id = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.rtable_public.id
}

###########################  private route table  ################
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

##########################  private route table association ###########
resource "aws_route_table_association" "priv" {
  for_each = toset(var.priv_cidr)
  subnet_id = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.rtable_private.id
}

#################   security groups  ###########################
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
