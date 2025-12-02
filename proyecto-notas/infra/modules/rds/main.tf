resource "aws_db_subnet_group" "this" {
  name       = "notes-rds-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "this" {
  identifier        = "notes-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = var.db_username
  password = var.db_password
  db_name  = var.db_name

  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot  = true
}
