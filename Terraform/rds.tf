data "aws_secretsmanager_secret" "db-connection" {
  name = "synthesis-db-connection"
}

resource "aws_secretsmanager_secret_version" "db-connection-string" {
  secret_id     = data.aws_secretsmanager_secret.db-connection.id
  secret_string =format("Initial catalog = synthesis; Server =%s ; user =%s; password =%s;",module.db.db_instance_endpoint,local.db_username,local.db_password)  
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "synthesis-sql-db"

  engine            = "sqlserver-ex"
  engine_version    = "15.00.4073.23.v1"
  instance_class    = "db.t3.small"
  allocated_storage = 20

  username = local.db_username
  password = local.db_password
  
  port     = "1433"
  

  multi_az               = false
  license_model             = "license-included"
  family = "sqlserver-ex-15.0"
  backup_retention_period = 2

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  enabled_cloudwatch_logs_exports = ["error"]


  tags = local.tags

  # DB subnet group
  subnet_ids = [aws_subnet.synthesis-subnet-private-1.id, aws_subnet.synthesis-subnet-private-2.id]
#create_db_subnet_group=true
db_subnet_group_name=aws_db_subnet_group.synthesis-subnet-group.name
  major_engine_version = "15.00"

  deletion_protection = false
  skip_final_snapshot=true
  publicly_accessible=false
 
  options = []
  create_db_parameter_group = false

  timeouts = {
    create = "180m"
    update = "90m"
    delete = "90m"
  } 
}