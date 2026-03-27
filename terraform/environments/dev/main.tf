module "vpc" {
  source = "../../modules/vpc"

  name   = var.project_name
 
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
  bastion_role_arn = module.ec2.bastion_role_arn
  jenkins_role_arn = module.jenkins_ec2.jenkins_role_arn
}

module "jenkins_ec2" {
  source = "../../modules/jenkins-ec2"

  public_subnet_id = module.vpc.public_subnets[0]
  vpc_id = module.vpc.vpc_id

}


module "ec2" {
  source = "../../modules/ec2"
  
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]

  cluster_name = var.cluster_name

  region = var.region
  cluster_security_group_id = module.eks.cluster_security_group_id

}


module "rds" {
  source = "../../modules/rds"

  db_subnets  = module.vpc.database_subnets
  db_user     = var.db_user
  db_password = var.db_password

  node_security_group_id = module.eks.node_security_group_id
  vpc_id = module.vpc.vpc_id
}
