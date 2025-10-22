module "vpc" {
  source        = "git::https://github.com/sivaganga9786/Terraform-foundation.git//terraform-modules/vpc"
  vpc_cidr            = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  cluster_name        = var.vpc_name
  availability_zones   = var.availability_zones
}

