resource "aws_secretsmanager_secret" "db-connection" {
  name = "synthesis-db-connection"

   rotation_rules {
    automatically_after_days = 30
  }
}
