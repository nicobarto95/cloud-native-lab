# 📊 Output Values for Cloud Native Lab Infrastructure

# ==============================================================================
# PROJECT INFORMATION
# ==============================================================================

output "project_info" {
  description = "Basic project information"
  value = {
    name        = var.project_name
    environment = var.environment
    owner       = var.owner
    region      = var.aws_region
  }
}

# ==============================================================================
# VPC OUTPUTS
# ==============================================================================

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_cidr       = module.vpc.vpc_cidr_block
    vpc_arn        = module.vpc.vpc_arn
    igw_id         = module.vpc.internet_gateway_id
    nat_gateway_ip = module.vpc.nat_gateway_public_ip
  }
}

output "subnets_info" {
  description = "Subnet information"
  value = {
    public_subnet_ids    = module.vpc.public_subnets
    public_subnet_cidrs  = module.vpc.public_subnet_cidrs
    private_subnet_ids   = module.vpc.private_subnets
    private_subnet_cidrs = module.vpc.private_subnet_cidrs
    availability_zones   = module.vpc.availability_zones
  }
}

# ==============================================================================
# INFRASTRUCTURE SUMMARY
# ==============================================================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    # Basic info
    project     = "${var.project_name}-${var.environment}"
    region      = var.aws_region
    created_at  = timestamp()
    
    # Network
    vpc_id      = module.vpc.vpc_id
    vpc_cidr    = module.vpc.vpc_cidr_block
    subnets     = length(module.vpc.public_subnets) + length(module.vpc.private_subnets)
    
    # Features enabled
    nat_gateway     = var.enable_nat_gateway
    vpn_gateway     = var.enable_vpn_gateway
    flow_logs       = var.enable_flow_logs
    elastic_ips     = var.create_elastic_ip
    
  }
}

# ==============================================================================
# VALIDATION OUTPUTS (For CI/CD)
# ==============================================================================

output "deployment_validation" {
  description = "Deployment validation status"
  value = {
    vpc_created        = module.vpc.vpc_id != null
    subnets_created    = length(module.vpc.public_subnets) > 0
    
    deployment_status = (
      module.vpc.vpc_id != null &&
      length(module.vpc.public_subnets) > 0
      ) ? "✅ SUCCESS" : "❌ INCOMPLETE"
  }
}