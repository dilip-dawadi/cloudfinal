#!/usr/bin/env bash
set -euo pipefail

# Initial Setup Script - Run this once before deployment
# Usage: ./scripts/setup.sh

echo "========================================="
echo "  AWS Cloud Final - Initial Setup"
echo "========================================="
echo ""

SSH_KEY_PATH="$HOME/.ssh/cloudfinal-key"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    echo "✅ SSH key already exists at: $SSH_KEY_PATH"
    echo ""
    read -p "Do you want to use the existing key? (yes/no): " USE_EXISTING
    
    if [ "$USE_EXISTING" != "yes" ]; then
        echo "⚠️  Generating new key will overwrite the existing one!"
        read -p "Are you sure? (yes/no): " CONFIRM
        
        if [ "$CONFIRM" != "yes" ]; then
            echo "❌ Setup cancelled."
            exit 0
        fi
        
        # Generate new SSH key
        echo ""
        echo "🔑 Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "cloudfinal-aws-key"
        echo "✅ SSH key generated!"
    fi
else
    # Generate SSH key
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "cloudfinal-aws-key"
    echo "✅ SSH key generated at: $SSH_KEY_PATH"
fi

echo ""
echo "📋 Your SSH public key:"
echo "========================================="
cat "${SSH_KEY_PATH}.pub"
echo "========================================="
echo ""

# Get the public key
SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")

# Update variables.tf with the SSH key
echo "📝 Updating variables.tf with your SSH key..."

# Use perl for cross-platform sed replacement
perl -i -pe 'BEGIN{undef $/;} s/variable "ssh_public_key" \{[^}]*default\s*=\s*"[^"]*"/variable "ssh_public_key" {\n  description = "SSH public key for EC2 instances"\n  type        = string\n  default     = "'"$SSH_PUBLIC_KEY"'"/smg' variables.tf

echo "✅ SSH key added to variables.tf"
echo ""

# Prompt for database password
echo "🔐 Database Password Setup"
echo "Current password: YourSecurePassword123!"
echo ""
read -p "Do you want to change the database password? (yes/no): " CHANGE_PASSWORD

if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo ""
    read -sp "Enter new database password: " DB_PASSWORD
    echo ""
    read -sp "Confirm password: " DB_PASSWORD_CONFIRM
    echo ""
    
    if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
        echo "❌ Passwords don't match!"
        exit 1
    fi
    
    if [ ${#DB_PASSWORD} -lt 8 ]; then
        echo "❌ Password must be at least 8 characters!"
        exit 1
    fi
    
    # Update password in variables.tf
    perl -i -pe 's/(default\s*=\s*")[^"]*("\s*#.*db_password)/$1'"$DB_PASSWORD"'$2/g' variables.tf
    
    # Update password in setup-db.sh
    perl -i -pe "s/(mysql.*-p')[^']*(')/\$1$DB_PASSWORD\$2/g" scripts/setup-db.sh
    
    echo "✅ Database password updated!"
fi

echo ""
echo "========================================="
echo "  ✅ Setup Complete!"
echo "========================================="
echo ""
echo "📝 Configuration Summary:"
echo "  - SSH Key: $SSH_KEY_PATH"
echo "  - SSH key added to variables.tf"
if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo "  - Database password updated"
else
    echo "  - Database password: YourSecurePassword123! (default)"
fi
echo ""
echo "🚀 Next step: Deploy your infrastructure"
echo "   ./scripts/deploy.sh"
echo ""
