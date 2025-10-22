variable "region" {
  default = "us-east-1"
}
variable "access_key" {
  default = "us-east-1"
}
variable "secret_key" {
  default = "us-east-1"
}

variable "volume_size" {
  default = 8
}

variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  description = "Availability zones"
}
variable "private_subnet_cidrs" {}
