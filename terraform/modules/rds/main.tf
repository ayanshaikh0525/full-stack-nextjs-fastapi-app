resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "postgres" {
  identifier = "fastapi-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "fastapi"
  username = var.db_user
  password = var.db_password

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.db.name

  skip_final_snapshot = true
}