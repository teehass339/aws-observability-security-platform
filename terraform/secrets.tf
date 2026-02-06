resource "aws_secretsmanager_secret" "app-secret" {
  name = "app/config"
}