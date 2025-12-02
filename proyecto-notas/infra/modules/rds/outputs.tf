output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_database_name" {
  value = aws_db_instance.this.db_name
}
