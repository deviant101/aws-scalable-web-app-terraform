# DB Subnet Group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS MySQL Database
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Disable enhanced monitoring to reduce costs
  enabled_cloudwatch_logs_exports = []
  monitoring_interval             = 0

  # Backup settings
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Single AZ deployment as per requirements
  multi_az = false

  # Skip final snapshot for lab environment
  skip_final_snapshot = true

  # Allow modifications
  apply_immediately = true

  # Disable deletion protection for lab environment
  deletion_protection = false

  # Public accessibility
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-database"
  }
}
