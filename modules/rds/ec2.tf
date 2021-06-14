resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}
resource "local_file" "pem_file" {
  filename = pathexpand("~/${var.key_name}.pem")
  file_permission = "400"
  sensitive_content = tls_private_key.key.private_key_pem
}
################################################################################
data "aws_subnet_ids" "example"{
vpc_id = var.vpc_id
tags = {  Name = "*public*"  }
}

resource "aws_instance" "ec2_instance"{
   for_each = data.aws_subnet_ids.example.ids
   ami = "ami-016247688579884a6"
   instance_type = "t2.micro"
   subnet_id = each.value
   associate_public_ip_address = true
   vpc_security_group_ids = [var.ec2_sg_id]
   key_name = var.key_name
}
