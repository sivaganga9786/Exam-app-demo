
# Get all VPCs and CIDR
########################################
data "aws_vpcs" "all" {}

locals {
  vpc_id   = data.aws_vpcs.all.ids[0]
}

data "aws_vpc" "selected" {
  id = local.vpc_id
}

locals {
  vpc_cidr = data.aws_vpc.selected.cidr_block
}

########################################
# Web ALB Security Group
########################################

module "web_sg" {
  source       = "git::https://github.com/sivaganga9786/Terraform-foundation.git//terraform-modules/security_groups"
  project_name = "web-sg"
  vpc_id       = local.vpc_id
  vpc_cidr     = local.vpc_cidr

  ingress_rules = [
    {
      description     = "Allow HTTP from Web ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    },
    {
      description = "Allow HTTP from Jenkins Server"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTP from Sonar Server"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Send traffic to Internal ALB via VPC CIDR (no SG reference)
  egress_rules = [
    {
      description = "Allow outbound to VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      description = "Allow outbound to Internet for SSM / updates"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]


}