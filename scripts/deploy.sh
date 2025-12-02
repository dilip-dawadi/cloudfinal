#!/usr/bin/env bash
set -euo pipefail

# Deploy AWS Infrastructure
# Usage: ./scripts/deploy.sh

echo "========================================="
echo "  AWS Cloud Final - Terraform Deploy"
echo "========================================="
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   brew install terraform"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI is not installed. Install for better management:"
    echo "   brew install awscli"
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Format Terraform files
echo "🎨 Formatting Terraform files..."
terraform fmt -recursive

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    echo "❌ Validation failed. Please fix errors above."
    exit 1
fi

# Create plan
echo ""
echo "📋 Creating deployment plan..."
PLAN_FILE="cloudfinal.plan"
terraform plan -out="${PLAN_FILE}"

# Ask for confirmation
echo ""
read -p "Do you want to apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Deployment cancelled."
    rm -f "${PLAN_FILE}"
    exit 0
fi

# Apply plan
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply "${PLAN_FILE}"

# Clean up plan file
rm -f "${PLAN_FILE}"

# Show outputs
echo ""
echo "========================================="
echo "  ✅ Deployment Complete!"
echo "========================================="
echo ""
terraform output

echo ""
echo "📝 Next Steps:"
echo "1. Note the bastion_public_ip and load_balancer_url above"
echo "2. SSH to bastion and create the database table"
echo "3. See DEPLOY.md for detailed post-deployment steps"
echo ""
