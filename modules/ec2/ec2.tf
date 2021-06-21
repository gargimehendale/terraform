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
resource "aws_instance" "ec2_instance"{
   count = "${length(var.public_subnet_id)}"
   ami = "ami-07bfd9965e7b972d1"
   instance_type = "t2.micro"
   associate_public_ip_address = true
   vpc_security_group_ids = [var.ec2_sg_id]
   key_name = var.key_name
   subnet_id = "${element(var.public_subnet_id, count.index)}"
   tags = {
   Name = "instance0${count.index+1}"
}
}



