# 🎯 Input Variables for Cloud Native Lab Infrastructure

# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "cloud-native-lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources (email or name)"
  type        = string
  default     = "devops-team"
}

# ==============================================================================
# AWS CONFIGURATION
# ==============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be a valid region format (e.g., eu-west-1)."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
  
  validation {
    condition     = length(var.availability_zones) >= 1 && length(var.availability_zones) <= 3
    error_message = "Must specify between 1 and 3 availability zones."
  }
}

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 1
    error_message = "At least one public subnet CIDR must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 1
    error_message = "At least one private subnet CIDR must be specified."
  }
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # ⚠️ Change this for production!
  
  validation {
    condition = alltrue([
      for ip in var.allowed_ssh_ips : can(cidrhost(ip, 0))
    ])
    error_message = "All SSH IPs must be valid CIDR blocks."
  }
}

# ==============================================================================
# VPC FEATURES (Cost Optimization Focused)
# ==============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

# ==============================================================================
# COMPUTE CONFIGURATION
# ==============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # ✅ Free tier eligible
  
  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium",
      "t3.micro", "t3.small", "t3.medium",
      "t3a.micro", "t3a.small", "t3a.medium"
    ], var.instance_type)
    error_message = "Instance type must be cost-optimized (t2/t3/t3a family)."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 3
    error_message = "Instance count must be between 0 and 3 for demo purposes."
  }
}

variable "create_demo_instance" {
  description = "Whether to create demo EC2 instances"
  type        = bool
  default     = true
}

variable "associate_public_ip" {
  description = "Associate public IP addresses to instances"
  type        = bool
  default     = true
}

# ==============================================================================
# SSH KEY CONFIGURATION
# ==============================================================================

variable "create_key_pair" {
  description = "Create new SSH key pair"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key content (required if create_key_pair is true)"
  type        = string
  default     = ""
  
  # 📝 Will be provided in terraform.tfvars
}

variable "existing_key_name" {
  description = "Name of existing key pair (used if create_key_pair is false)"
  type        = string
  default     = ""
}

# ==============================================================================
# STORAGE CONFIGURATION
# ==============================================================================

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
  
  validation {
    condition     = contains(["gp2", "gp3"], var.root_volume_type)
    error_message = "Root volume type must be gp2 or gp3 for cost optimization."
  }
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 30
    error_message = "Root volume size must be between 8 and 30 GB for cost optimization."
  }
}

variable "encrypt_volumes" {
  description = "Encrypt EBS volumes"
  type        = bool
  default     = true
}

# ==============================================================================
# OPTIONAL FEATURES (Cost Optimization)
# ==============================================================================

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

variable "termination_protection" {
  description = "Enable EC2 termination protection"
  type        = bool
  default     = false  # 🧹 Disabled for easy cleanup
}

variable "create_elastic_ip" {
  description = "Create Elastic IP for instances (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

# ==============================================================================
# MONITORING CONFIGURATION (Future)
# ==============================================================================

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}

variable "enable_cloudwatch_metrics" {
  description = "Enable custom CloudWatch metrics (costs extra)"
  type        = bool
  default     = false  # 💰 Disabled for cost optimization
}