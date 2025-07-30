variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}