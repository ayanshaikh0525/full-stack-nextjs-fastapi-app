module "vpc" {
  source = "../../modules/vpc"

  name   = var.project_name
 
}


module "rds" {
  source = "../../modules/rds"

  db_subnets  = module.vpc.database_subnets
  db_user     = var.db_user
  db_password = var.db_password
}


module "ecr" {
  source = "../../modules/ecr"

  repo_name = var.repo_name
}


module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}