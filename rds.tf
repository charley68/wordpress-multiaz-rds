#rds subnet
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
#RDS INSTANCE
resource "aws_db_instance" "rds_instance" {
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project}-final-snapshot"
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  identifier                = "${var.project}-rds-instance"
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]

  tags = {
    Name = "RDS Instance"
  }
}
# RDS security group
resource "aws_security_group" "rds_security_group" {
  name        = "${var.project}-rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}