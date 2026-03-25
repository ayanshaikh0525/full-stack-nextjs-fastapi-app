resource "aws_ecr_repository" "app" {
  name = var.repo_name
}