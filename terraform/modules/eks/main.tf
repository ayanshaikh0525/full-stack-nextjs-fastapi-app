module "eks" {
  source = "terraform-aws-modules/eks/aws"
   version = "~> 20.0"
     
  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
    }
  }


  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true



}


resource "aws_eks_access_entry" "ayan" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::928413605425:user/ayan-development"
  type          = "STANDARD"
}


resource "aws_eks_access_policy_association" "ayan_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::928413605425:user/ayan-development"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}


