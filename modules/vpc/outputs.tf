output "vpc_id"{
value = aws_vpc.myvpc.id
}
output "private_subnet_id"{
value = tolist(data.aws_subnet_ids.private_subnet_id.ids)
}
output "public_subnet_id"{
value = tolist(data.aws_subnet_ids.public_subnet_id.ids)
}
output "rds_sg_id"{
value = aws_security_group.sg_rds.id
}
output "ec2_sg_id"{
value = aws_security_group.sg_ec2.id
}
