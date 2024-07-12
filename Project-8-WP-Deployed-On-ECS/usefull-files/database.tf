################
# Database RDS #
################

resource "aws_db_subnet_group" "default" {
  name       = "db_subnet-${var.name}"
  subnet_ids = [aws_subnet.subnets["subnet-1"].id, aws_subnet.subnets["subnet-2"].id]

  tags = {
    Name = "DB-Subnet-${var.name}"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.p8_sg.id]
  identifier             = "mydb"
  publicly_accessible    = true
}
