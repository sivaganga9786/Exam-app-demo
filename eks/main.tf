provider "aws" {
  region = "us-east-1"
}
# ===============================
# Get the first VPC
# ===============================
data "aws_vpcs" "all" {}

locals {
  vpc_id = data.aws_vpcs.all.ids[0]
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

locals {
  app_subnets = [
    for s in data.aws_subnet.details :
    s.id if can(regex("app-tier", lower(lookup(s.tags, "Name", ""))))
  ]

  web_subnets = [
    for s in data.aws_subnet.details :
    s.id if can(regex("web-tier", lower(lookup(s.tags, "Name", ""))))
  ]
}



module "eks" {
  source = "git::https://github.com/sivaganga9786/Terraform-foundation.git//terraform-modules/eks"
  cluster_name    = "examapp-cluster"
  cluster_version = "1.30"
  subnet_id       = local.web_subnets
  node_groups = {
    default = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
    }
  }
}
