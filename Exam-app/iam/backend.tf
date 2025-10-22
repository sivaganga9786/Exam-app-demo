terraform {
  backend "s3" {
    bucket         = "terraformec2346536567"
    key            = "iam/terraform.tfstate"
    region         = "us-east-1"
  }
}