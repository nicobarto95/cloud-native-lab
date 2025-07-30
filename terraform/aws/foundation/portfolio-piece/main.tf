provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
  environment = var.environment
  }

module "compute" {
  source        = "./modules/compute"
  instance_type = var.instance_type
  env           = var.environment
}
