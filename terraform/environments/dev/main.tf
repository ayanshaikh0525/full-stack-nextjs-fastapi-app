module "vpc" {
  source = "../../modules/vpc"

  name   = var.project_name
  region = var.region
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "fastapi-cluster"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "rds" {
  source = "../../modules/rds"

  db_subnets  = module.vpc.database_subnets
  db_user     = var.db_user
  db_password = var.db_password
}

module "ecr" {
  source = "../../modules/ecr"

  repo_name = "fastapi-app"
}
