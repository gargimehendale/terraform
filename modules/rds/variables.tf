variable "private_subnet_id"{
type = list
}
variable "public_subnet_id"{
type = list
}
variable "vpc_id"{}
variable "rds_sg_id"{
type = string
}
variable "ec2_sg_id"{
type = string
}
variable "key_name"{
type = string
default = "aws_instance_key"
}
