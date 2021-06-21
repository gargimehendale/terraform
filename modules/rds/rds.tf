resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = "${var.private_subnet_id}"
tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "rds_instance"{
  depends_on = [aws_db_subnet_group.default]
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "12.5"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "postgres"
  password             = "gargi123"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot  = true
}
