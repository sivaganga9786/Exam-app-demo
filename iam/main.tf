# EC2 Assume Role Document
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role with custom managed policies
module "ec2_role" {
  source             = "git::https://github.com/sivaganga9786/Terraform-foundation.git//terraform-modules/iam"
  role_name          = var.role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  # AWS managed policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Custom managed policies
  custom_managed_policies = {
    "SSM-CloudWatch-S3-SessionManager" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "ssm:*",
            "ssmmessages:*",
            "ec2messages:*",
            "cloudwatch:*",
            "logs:*",
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "*"
        }
      ]
    })
  }

  # Extra inline policies
  extra_inline_policies = var.extra_inline_policies
}
