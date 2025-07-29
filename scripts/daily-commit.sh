#!/bin/bash
# 🤖 Daily Commit Automation Script
# Usage: ./scripts/daily-commit.sh [custom-message]

set -e

# Configuration
LEARNING_DIR="docs/learning"
LEARNING_FILE="$LEARNING_DIR/daily-log.md"
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create learning directory if not exists
mkdir -p "$LEARNING_DIR"

echo -e "${BLUE}🚀 Starting daily learning commit automation...${NC}"

# Function to add learning entry
add_learning_entry() {
    local custom_message="$1"
    
    if [ ! -f "$LEARNING_FILE" ]; then
        echo "# 📚 Daily Learning Journey" > "$LEARNING_FILE"
        echo "" >> "$LEARNING_FILE"
        echo "A continuous learning log documenting my DevOps and Platform Engineering growth." >> "$LEARNING_FILE"
        echo "" >> "$LEARNING_FILE"
    fi
    
    # Add daily entry
    cat >> "$LEARNING_FILE" << EOF

## 📅 $DATE - $TIME

### 🎯 Today's Focus:
EOF

    if [ -n "$custom_message" ]; then
        echo "- $custom_message" >> "$LEARNING_FILE"
    else
        # Random learning topics for variety
        TOPICS=(
            "Exploring Kubernetes networking and service mesh patterns"
            "Deep diving into Terraform advanced features and best practices"
            "Investigating GitOps workflows and ArgoCD configurations"
            "Studying cloud-native security and zero-trust architectures"
            "Researching container orchestration optimization techniques"
            "Learning about observability and monitoring stack improvements"
            "Analyzing infrastructure cost optimization strategies"
            "Exploring CI/CD pipeline automation and enhancement"
            "Investigating multi-cloud deployment patterns"
            "Studying platform engineering and developer experience"
        )
        
        # Select random topic
        RANDOM_TOPIC=${TOPICS[$RANDOM % ${#TOPICS[@]}]}
        echo "- $RANDOM_TOPIC" >> "$LEARNING_FILE"
    fi
    
    cat >> "$LEARNING_FILE" << EOF

### 📝 Progress Notes:
- Continued building production-ready infrastructure patterns
- Enhanced automation scripts and improved workflow efficiency
- Contributed to open source projects and community discussions

### 🔗 Resources:
- [CNCF Landscape](https://landscape.cncf.io/) - Exploring cloud native technologies
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Official K8s docs
- [Terraform Registry](https://registry.terraform.io/) - Module exploration

---
EOF
}

# Function to update project stats
update_project_stats() {
    local stats_file="docs/project-stats.md"
    local repo_count=$(find . -name ".git" -type d | wc -l)
    local tf_files=$(find . -name "*.tf" | wc -l)
    local k8s_files=$(find . -name "*.yaml" -o -name "*.yml" | grep -E "(k8s|kubernetes)" | wc -l)
    
    cat > "$stats_file" << EOF
# 📊 Project Statistics

> Last updated: $DATE $TIME

## 📈 Repository Metrics
- **Total Projects**: $repo_count
- **Terraform Files**: $tf_files
- **Kubernetes Manifests**: $k8s_files
- **Days of Learning**: $(grep -c "^## 📅" "$LEARNING_FILE" 2>/dev/null || echo "1")

## 🎯 Current Streak
- **Consistent Learning**: Building cloud-native expertise daily
- **Focus Area**: Production-ready infrastructure automation
- **Next Milestone**: 90-day continuous learning streak

## 🚀 Recent Achievements
- ✅ Multi-cloud lab environment setup
- ✅ Kubernetes automation workflows
- ✅ Terraform module standardization
- ✅ CI/CD pipeline optimization
EOF
}

# Main execution
echo -e "${YELLOW}📝 Adding learning entry...${NC}"
add_learning_entry "$1"

echo -e "${YELLOW}📊 Updating project statistics...${NC}"
update_project_stats

# Git operations
echo -e "${YELLOW}🔄 Committing changes...${NC}"

# Add files
git add "$LEARNING_FILE" docs/project-stats.md

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️  No changes to commit today${NC}"
    exit 0
fi

# Commit with meaningful message
if [ -n "$1" ]; then
    COMMIT_MSG="docs: daily learning - $1"
else
    COMMIT_MSG="docs: daily learning progress and project updates"
fi

git commit -m "$COMMIT_MSG"

# Push to remote
echo -e "${YELLOW}🚀 Pushing to remote...${NC}"
git push origin main

echo -e "${GREEN}✅ Daily commit automation completed successfully!${NC}"
echo -e "${BLUE}📊 View your progress: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git.*/\1\/\2/')${NC}"

