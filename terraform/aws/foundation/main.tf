# 🚀 Cloud Native Lab - Main Orchestrator
# Enterprise-grade infrastructure with cost optimization

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 📝 Uncomment for remote state management
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cloud-native-lab/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}


# 🌍 AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# 📊 Local Values for Configuration
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "cloud-native-lab"
    Owner       = var.owner
    CostCenter  = "development"
  }
}

# 🌐 VPC Module - Network Foundation
module "vpc" {
  source = "../modules/vpc"

  # Basic configuration
  name = var.project_name

  # Network configuration
  vpc_cidr = var.vpc_cidr

  # Subnets configuration
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  # Features (cost-optimized for demo)
  enable_nat_gateway   = var.enable_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_flow_logs     = var.enable_flow_logs

}
