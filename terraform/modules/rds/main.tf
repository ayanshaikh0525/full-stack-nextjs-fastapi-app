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

  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.db.name

  skip_final_snapshot = true

}

resource "aws_security_group" "rds" {
  name        = "rds-postgres-sg"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "rds-postgres-sg"
  }
}

resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.node_security_group_id
  # cidr_blocks = ["0.0.0.0/0"]
}