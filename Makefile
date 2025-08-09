# Makefile for Cloud Native Lab Terraform Automation
# 🚀 Enterprise-grade commands for infrastructure management

.PHONY: help init plan apply destroy clean fmt validate check cost ssh status

# Default target
.DEFAULT_GOAL := help

# Configuration
TERRAFORM_DIR := terraform/aws/foundation
VAR_FILE := terraform.tfvars

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
PURPLE := \033[35m
CYAN   := \033[36m
WHITE  := \033[37m
RESET  := \033[0m

##@ 🎯 Main Commands

help: ## 📋 Show this help message
	@echo "$(CYAN)Cloud Native Lab - Terraform Commands$(RESET)"
	@echo "$(BLUE)======================================$(RESET)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

init: ## 🏁 Initialize Terraform backend and providers
	@echo "$(BLUE)🏁 Initializing Terraform...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform init
	@echo "$(GREEN)✅ Terraform initialized successfully!$(RESET)"

plan: ## 📊 Plan Terraform deployment (preview changes)
	@echo "$(BLUE)📊 Planning Terraform deployment...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform plan -var-file="$(VAR_FILE)" -out=tfplan
	@echo "$(GREEN)✅ Plan completed! Review the changes above.$(RESET)"

apply: ## 🚀 Apply Terraform configuration (deploy infrastructure)
	@echo "$(BLUE)🚀 Applying Terraform configuration...$(RESET)"
	@echo "$(YELLOW)⚠️  This will create real AWS resources that may incur costs!$(RESET)"
	cd $(TERRAFORM_DIR) && terraform apply -var-file="$(VAR_FILE)" -auto-approve
	@echo "$(GREEN)✅ Infrastructure deployed successfully!$(RESET)"
	@echo "$(CYAN)🎉 Run 'make ssh' to connect to your instances$(RESET)"

destroy: ## 💥 Destroy all Terraform-managed resources
	@echo "$(RED)💥 Destroying all infrastructure...$(RESET)"
	@echo "$(YELLOW)⚠️  This will permanently delete all resources!$(RESET)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy -var-file="$(VAR_FILE)" -auto-approve; \
		echo "$(GREEN)✅ All resources destroyed!$(RESET)"; \
	else \
		echo "$(YELLOW)❌ Destruction cancelled$(RESET)"; \
	fi

##@ 🛠️ Development Commands

fmt: ## 🎨 Format all Terraform files
	@echo "$(BLUE)🎨 Formatting Terraform files...$(RESET)"
	terraform fmt -recursive terraform/
	@echo "$(GREEN)✅ All files formatted!$(RESET)"

validate: ## ✅ Validate Terraform configuration
	@echo "$(BLUE)✅ Validating Terraform configuration...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform validate
	@echo "$(GREEN)✅ Configuration is valid!$(RESET)"

check: fmt validate ## 🔍 Run format and validation checks
	@echo "$(GREEN)✅ All checks passed!$(RESET)"

##@ 📊 Monitoring Commands

status: ## 📈 Show current infrastructure status
	@echo "$(BLUE)📈 Infrastructure Status$(RESET)"
	@echo "$(BLUE)======================$(RESET)"
	cd $(TERRAFORM_DIR) && terraform show -json 2>/dev/null | jq -r '
		.values.root_module.resources[] | 
		select(.type == "aws_instance") | 
		"Instance: \(.values.tags.Name) (\(.values.instance_type)) - \(.values.instance_state)"
	' 2>/dev/null || echo "$(YELLOW)⚠️  No infrastructure deployed or jq not installed$(RESET)"

cost: ## 💰 Estimate monthly costs
	@echo "$(BLUE)💰 Cost Estimation$(RESET)"
	@echo "$(BLUE)=================$(RESET)"
	cd $(TERRAFORM_DIR) && terraform output cost_estimation 2>/dev/null || echo "$(YELLOW)⚠️  No infrastructure deployed$(RESET)"

ssh: ## 🔑 Get SSH connection commands
	@echo "$(BLUE)🔑 SSH Connection Commands$(RESET)"
	@echo "$(BLUE)=========================$(RESET)"
	cd $(TERRAFORM_DIR) && terraform output -json ssh_access 2>/dev/null | jq -r '.ssh_commands[]' || echo "$(YELLOW)⚠️  No SSH access available$(RESET)"

outputs: ## 📤 Show all Terraform outputs
	@echo "$(BLUE)📤 All Terraform Outputs$(RESET)"
	@echo "$(BLUE)========================$(RESET)"
	cd $(TERRAFORM_DIR) && terraform output

##@ 🧹 Utility Commands

clean: ## 🧹 Clean Terraform temporary files
	@echo "$(BLUE)🧹 Cleaning temporary files...$(RESET)"
	find terraform/ -name "*.tfplan" -delete
	find terraform/ -name "*.tfstate.backup" -delete
	find terraform/ -name ".terraform.lock.hcl" -delete
	find terraform/ -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Cleanup completed!$(RESET)"

setup: ## ⚙️ Initial project setup (copy tfvars template)
	@echo "$(BLUE)⚙️ Setting up project...$(RESET)"
	@if [ ! -f $(TERRAFORM_DIR)/$(VAR_FILE) ]; then \
		cp $(TERRAFORM_DIR)/terraform.tfvars.example $(TERRAFORM_DIR)/$(VAR_FILE); \
		echo "$(GREEN)✅ Created $(VAR_FILE) from template$(RESET)"; \
		echo "$(YELLOW)📝 Please edit $(TERRAFORM_DIR)/$(VAR_FILE) with your configuration$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  $(VAR_FILE) already exists$(RESET)"; \
	fi

##@ 🚀 Quick Deploy Workflows

quick-deploy: setup init plan apply ## ⚡ Quick deployment (setup → init → plan → apply)
	@echo "$(GREEN)🎉 Quick deployment completed!$(RESET)"
	@echo "$(CYAN)Run 'make ssh' to connect to your instances$(RESET)"

full-destroy: destroy clean ## 💣 Complete destruction (destroy → clean)
	@echo "$(GREEN)✅ Complete destruction finished!$(RESET)"

##@ 🔧 Advanced Commands

refresh: ## 🔄 Refresh Terraform state
	@echo "$(BLUE)🔄 Refreshing Terraform state...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform refresh -var-file="$(VAR_FILE)"
	@echo "$(GREEN)✅ State refreshed!$(RESET)"

graph: ## 📊 Generate dependency graph (requires graphviz)
	@echo "$(BLUE)📊 Generating dependency graph...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform graph | dot -Tpng > terraform-graph.png
	@echo "$(GREEN)✅ Graph saved as terraform-graph.png$(RESET)"

backup: ## 💾 Backup Terraform state
	@echo "$(BLUE)💾 Backing up Terraform state...$(RESET)"
	@mkdir -p backups
	cp $(TERRAFORM_DIR)/terraform.tfstate backups/terraform-$(shell date +%Y%m%d-%H%M%S).tfstate.backup
	@echo "$(GREEN)✅ State backed up to backups/$(RESET)"

##@ 📚 Documentation Commands

docs: ## 📚 Generate Terraform documentation
	@echo "$(BLUE)📚 Generating documentation...$(RESET)"
	@command -v terraform-docs >/dev/null 2>&1 || { echo "$(RED)❌ terraform-docs not installed$(RESET)"; exit 1; }
	terraform-docs markdown table terraform/aws/modules/vpc/ > docs/vpc-module.md
	terraform-docs markdown table terraform/aws/modules/security/ > docs/security-module.md  
	terraform-docs markdown table terraform/aws/modules/compute/ > docs/compute-module.md
	@echo "$(GREEN)✅ Documentation generated in docs/$(RESET)"

##@ 🐛 Troubleshooting Commands

debug: ## 🐛 Enable Terraform debug logging
	@echo "$(BLUE)🐛 Debug mode enabled$(RESET)"
	@echo "$(YELLOW)Set TF_LOG=DEBUG for detailed logging$(RESET)"
	@export TF_LOG=DEBUG && $(MAKE) plan

test: ## 🧪 Test Terraform configuration
	@echo "$(BLUE)🧪 Testing configuration...$(RESET)"
	cd $(TERRAFORM_DIR) && terraform plan -var-file="$(VAR_FILE)" -detailed-exitcode
	@echo "$(GREEN)✅ Configuration test completed!$(RESET)"

##@ ℹ️ Information Commands

version: ## 📋 Show Terraform version
	@terraform version

requirements: ## 📋 Check system requirements
	@echo "$(BLUE)📋 System Requirements Check$(RESET)"
	@echo "$(BLUE)===========================$(RESET)"
	@command -v terraform >/dev/null 2>&1 && echo "$(GREEN)✅ Terraform installed$(RESET)" || echo "$(RED)❌ Terraform not installed$(RESET)"
	@command -v aws >/dev/null 2>&1 && echo "$(GREEN)✅ AWS CLI installed$(RESET)" || echo "$(RED)❌ AWS CLI not installed$(RESET)"
	@command -v jq >/dev/null 2>&1 && echo "$(GREEN)✅ jq installed$(RESET)" || echo "$(YELLOW)⚠️  jq not installed (optional)$(RESET)"
	@aws sts get-caller-identity >/dev/null 2>&1 && echo "$(GREEN)✅ AWS credentials configured$(RESET)" || echo "$(RED)❌ AWS credentials not configured$(RESET)"

##@ 💡 Examples

example-dev: ## 💡 Show example for development environment
	@echo "$(CYAN)💡 Development Environment Example:$(RESET)"
	@echo "make setup"
	@echo "# Edit terraform.tfvars with your values"
	@echo "make init"
	@echo "make plan"
	@echo "make apply"
	@echo "make ssh"

example-production: ## 💡 Show example for production deployment
	@echo "$(CYAN)💡 Production Environment Example:$(RESET)"
	@echo "# 1. Setup remote state backend first"
	@echo "# 2. Configure production values in terraform.tfvars"
	@echo "make init"
	@echo "make plan > plan.out"
	@echo "# Review plan.out carefully"
	@echo "make apply"
	@echo "make backup"