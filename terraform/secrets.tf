# AWS Secrets Manager Secret for Database Credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "Mydbsecret"
  description = "Database secret for web app"

  tags = {
    Name = "${var.project_name}-db-secret"
  }
}

# Secret Version with Database Connection Details
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    user     = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.address
    db       = var.db_name
  })
}
