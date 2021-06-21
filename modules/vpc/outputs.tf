output "vpc_id"{
value = aws_vpc.myvpc.id
}
output "private_subnet_id"{
value = "${aws_subnet.private_subnet.*.id}"
}
output "public_subnet_id"{
value = "${aws_subnet.public_subnet.*.id}"
}
output "rds_sg_id"{
value = aws_security_group.sg_rds.id
}
output "ec2_sg_id"{
value = aws_security_group.sg_ec2.id
}
