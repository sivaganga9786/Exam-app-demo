variable "role_name" {
  type    = string
  default = "ec2_ssm_role"
}

variable "extra_inline_policies" {
  type    = map(string)
  default = {}
}
