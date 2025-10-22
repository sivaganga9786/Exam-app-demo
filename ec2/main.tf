# ===============================
# Get the first VPC
# ===============================
data "aws_vpcs" "all" {}

locals {
  vpc_id = data.aws_vpcs.all.ids[0]
}

# ===============================
# Get all subnets in the VPC
# ===============================
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

# ===============================
# Get subnet details
# ===============================
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

# ===============================
# Filter private (app) and public (web) subnets by Name tag
# ===============================
locals {

  web_subnets = [
    for s in data.aws_subnet.details :
    s.id if can(regex("web-tier", lower(lookup(s.tags, "Name", ""))))
  ]
}

# ===============================
# Security Groups
# ===============================

data "aws_security_group" "web_sg" {
  filter {
    name   = "group-name"
    values = ["web-sg-sg"]
  }
}

# ===============================
# Get the latest Amazon Linux 2023 AMI
# ===============================
# data "aws_ami" "amazon_linux_2023" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }
# ===============================
# Get the latest UBUNTU AMI
# ===============================

data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (official Ubuntu publisher)

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ===============================
# Web EC2 Instance (Public Subnet)
# ===============================
module "Examapp_instance" {
  source               = "git::https://github.com/sivaganga9786/Terraform-foundation.git//terraform-modules/ec2"
 # ami_id               = data.aws_ami.amazon_linux_2023.id
  ami_id               = data.aws_ami.ubuntu_24_04.id
  instance_type        = "t2.large"
  subnet_id            = local.web_subnets[0]
  security_group_ids   = [data.aws_security_group.web_sg.id]
  iam_instance_profile = "ec2_ssm_role-instance-profile"
  project_name         = "exam-app"
  role                 = "exam-app-server"
  #user_data = file("${path.module}/jenkins.sh")
  user_data = join("\n", [
      file("${path.module}/trivy.sh"),
      file("${path.module}/jenkins.sh"),
      file("${path.module}/docker.sh"),
      file("${path.module}/sonar.sh")
    ])

}

