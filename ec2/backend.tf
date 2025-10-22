terraform {
  backend "s3" {
    bucket         = "terraformec2346536567"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
  }
}