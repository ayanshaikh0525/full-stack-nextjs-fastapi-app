terraform {
  backend "s3" {
    bucket         = "full-stack-app-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
