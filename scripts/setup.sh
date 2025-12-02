#!/usr/bin/env bash
set -euo pipefail

# Initial Setup Script - Run this once before deployment
# Usage: ./scripts/setup.sh

echo "========================================="
echo "  AWS Cloud Final - Initial Setup"
echo "========================================="
echo ""

# Check for existing SSH key in configuration first
TFVARS_FILE="terraform.tfvars"
CURRENT_SSH_KEY=""
CURRENT_SSH_KEY_FULL=""

if [ -f "$TFVARS_FILE" ] && grep -q "^ssh_public_key" "$TFVARS_FILE"; then
    CURRENT_SSH_KEY_FULL=$(grep "^ssh_public_key" "$TFVARS_FILE" | sed 's/ssh_public_key = "\(.*\)"/\1/')
    CURRENT_SSH_KEY=$(echo "$CURRENT_SSH_KEY_FULL" | cut -c 1-60)
elif [ -f "variables.tf" ]; then
    CURRENT_SSH_KEY_FULL=$(grep -A 1 'variable "ssh_public_key"' variables.tf | grep 'default' | sed 's/.*default.*=.*"\(.*\)".*/\1/')
    CURRENT_SSH_KEY=$(echo "$CURRENT_SSH_KEY_FULL" | cut -c 1-60)
fi

# If SSH key exists in config, ask if they want to use it
if [ -n "$CURRENT_SSH_KEY_FULL" ]; then
    echo "🔍 Found existing SSH key in configuration:"
    echo "   ${CURRENT_SSH_KEY}..."
    echo ""
    read -p "Do you want to keep using this SSH key? (yes/no): " KEEP_CURRENT
    
    if [ "$KEEP_CURRENT" = "yes" ]; then
        SSH_PUBLIC_KEY="$CURRENT_SSH_KEY_FULL"
        echo "✅ Using existing SSH key from configuration"
        SKIP_SSH_SELECTION=true
    else
        echo ""
        echo "🔍 Checking for SSH keys in ~/.ssh..."
        SKIP_SSH_SELECTION=false
    fi
else
    echo "🔍 Checking for existing SSH keys..."
    SKIP_SSH_SELECTION=false
fi

# Only scan for keys if user didn't keep the current one
if [ "$SKIP_SSH_SELECTION" != "true" ]; then
    echo ""
    EXISTING_KEYS=()
    SSH_DIR="$HOME/.ssh"

    if [ -d "$SSH_DIR" ]; then
        # Find all SSH private keys (files with corresponding .pub files)
        while IFS= read -r key; do
            if [ -f "${key}.pub" ]; then
                EXISTING_KEYS+=("$key")
            fi
        done < <(find "$SSH_DIR" -type f \( -name "id_*" -o -name "*_rsa" -o -name "*-key" \) ! -name "*.pub" 2>/dev/null)
    fi

    # Display existing keys if found
    if [ ${#EXISTING_KEYS[@]} -gt 0 ]; then
        echo "✅ Found existing SSH key(s) in ~/.ssh:"
        for i in "${!EXISTING_KEYS[@]}"; do
            echo "   [$((i+1))] ${EXISTING_KEYS[$i]}"
        done
        echo ""
        
        read -p "Do you want to use one of these keys? (yes/no): " USE_EXISTING
        
        if [ "$USE_EXISTING" = "yes" ]; then
            if [ ${#EXISTING_KEYS[@]} -eq 1 ]; then
                SSH_KEY_PATH="${EXISTING_KEYS[0]}"
                echo "✅ Using: $SSH_KEY_PATH"
            else
                echo ""
                read -p "Enter the number of the key to use [1-${#EXISTING_KEYS[@]}]: " KEY_NUM
                
                if [[ "$KEY_NUM" =~ ^[0-9]+$ ]] && [ "$KEY_NUM" -ge 1 ] && [ "$KEY_NUM" -le ${#EXISTING_KEYS[@]} ]; then
                    SSH_KEY_PATH="${EXISTING_KEYS[$((KEY_NUM-1))]}"
                    echo "✅ Using: $SSH_KEY_PATH"
                else
                    echo "❌ Invalid selection"
                    exit 1
                fi
            fi
        else
            echo ""
            read -p "Do you want to (1) specify a different key path or (2) create a new key? [1/2]: " CHOICE
            
            if [ "$CHOICE" = "1" ]; then
                # Specify custom path
                echo ""
                read -p "Enter the path to your SSH private key: " SSH_KEY_PATH
                SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"
                
                if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "${SSH_KEY_PATH}.pub" ]; then
                    echo "❌ SSH key or public key not found at: $SSH_KEY_PATH"
                    exit 1
                fi
                echo "✅ Using: $SSH_KEY_PATH"
            else
                # Create new key
                echo ""
                read -p "Enter a name for your new SSH key [default: cloudfinal-key]: " KEY_NAME
                KEY_NAME=${KEY_NAME:-cloudfinal-key}
                
                SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"
                
                if [ -f "$SSH_KEY_PATH" ]; then
                    echo "⚠️  SSH key already exists at: $SSH_KEY_PATH"
                    read -p "Do you want to overwrite it? (yes/no): " OVERWRITE
                    
                    if [ "$OVERWRITE" != "yes" ]; then
                        echo "❌ Setup cancelled."
                        exit 0
                    fi
                fi
                
                echo "🔑 Generating SSH key..."
                mkdir -p "$HOME/.ssh"
                ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "aws-$KEY_NAME"
                echo "✅ SSH key generated at: $SSH_KEY_PATH"
            fi
        fi
    else
        # No existing keys found
        echo "ℹ️  No existing SSH keys found in $SSH_DIR"
        echo ""
        read -p "Do you want to (1) specify a key path or (2) create a new key? [1/2]: " CHOICE
        
        if [ "$CHOICE" = "1" ]; then
            # Specify custom path
            echo ""
            read -p "Enter the path to your SSH private key: " SSH_KEY_PATH
            SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"
            
            if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "${SSH_KEY_PATH}.pub" ]; then
                echo "❌ SSH key or public key not found at: $SSH_KEY_PATH"
                exit 1
            fi
            echo "✅ Using: $SSH_KEY_PATH"
        else
            # Create new key
            echo ""
            read -p "Enter a name for your new SSH key [default: cloudfinal-key]: " KEY_NAME
            KEY_NAME=${KEY_NAME:-cloudfinal-key}
            
            SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"
            
            if [ -f "$SSH_KEY_PATH" ]; then
                echo "⚠️  SSH key already exists at: $SSH_KEY_PATH"
                read -p "Do you want to overwrite it? (yes/no): " OVERWRITE
                
                if [ "$OVERWRITE" != "yes" ]; then
                    echo "❌ Setup cancelled."
                    exit 0
                fi
            fi
            
            echo "🔑 Generating SSH key..."
            mkdir -p "$HOME/.ssh"
            ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "aws-$KEY_NAME"
            echo "✅ SSH key generated at: $SSH_KEY_PATH"
        fi
    fi
    
    echo ""
    echo "📋 Your SSH public key:"
    echo "========================================="
    cat "${SSH_KEY_PATH}.pub"
    echo "========================================="
    echo ""
    
    # Get the public key
    SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")
fi

# Check if terraform.tfvars exists
TFVARS_FILE="terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "📝 Creating terraform.tfvars for secure configuration..."
    cat > "$TFVARS_FILE" << EOF
# Terraform Variables - Secure Configuration
# This file is in .gitignore and won't be committed

# SSH Configuration
ssh_public_key = "$SSH_PUBLIC_KEY"

# Database Configuration (update if needed)
db_password = "YourSecurePassword123!"
EOF
    echo "✅ Created terraform.tfvars with your SSH key"
else
    echo "📝 Updating terraform.tfvars with your SSH key..."
    
    # Check if ssh_public_key already exists in the file
    if grep -q "^ssh_public_key" "$TFVARS_FILE"; then
        # Update existing entry
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^ssh_public_key.*|ssh_public_key = \"$SSH_PUBLIC_KEY\"|" "$TFVARS_FILE"
        else
            sed -i "s|^ssh_public_key.*|ssh_public_key = \"$SSH_PUBLIC_KEY\"|" "$TFVARS_FILE"
        fi
    else
        # Add new entry
        echo "" >> "$TFVARS_FILE"
        echo "# SSH Configuration" >> "$TFVARS_FILE"
        echo "ssh_public_key = \"$SSH_PUBLIC_KEY\"" >> "$TFVARS_FILE"
    fi
    
    echo "✅ SSH key added to terraform.tfvars"
fi
echo ""

# Get current database password (check tfvars first, then variables.tf)
CURRENT_DB_PASSWORD=""
if [ -f "$TFVARS_FILE" ] && grep -q "^db_password" "$TFVARS_FILE"; then
    CURRENT_DB_PASSWORD=$(grep "^db_password" "$TFVARS_FILE" | sed 's/.*"\(.*\)".*/\1/')
elif [ -f "variables.tf" ]; then
    CURRENT_DB_PASSWORD=$(grep -A 3 'variable "db_password"' variables.tf | grep 'default' | sed 's/.*"\(.*\)".*/\1/')
fi

# Default if nothing found
if [ -z "$CURRENT_DB_PASSWORD" ]; then
    CURRENT_DB_PASSWORD="YourSecurePassword123!"
fi

# Get current SSH key (check tfvars first, then variables.tf)
CURRENT_SSH_KEY=""
if [ -f "$TFVARS_FILE" ] && grep -q "^ssh_public_key" "$TFVARS_FILE"; then
    CURRENT_SSH_KEY=$(grep "^ssh_public_key" "$TFVARS_FILE" | sed 's/.*"\(.*\)".*/\1/' | cut -c 1-50)
elif [ -f "variables.tf" ]; then
    CURRENT_SSH_KEY=$(grep -A 3 'variable "ssh_public_key"' variables.tf | grep 'default' | sed 's/.*"\(.*\)".*/\1/' | cut -c 1-50)
fi

# Show current configuration
if [ -n "$CURRENT_SSH_KEY" ]; then
    echo "ℹ️  Current SSH key in config: ${CURRENT_SSH_KEY}..."
fi

# Prompt for database password
echo ""
echo "🔐 Database Password Setup"
echo "Current password: $CURRENT_DB_PASSWORD"
echo ""
read -p "Do you want to change the database password? (yes/no): " CHANGE_PASSWORD

if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo ""
    read -sp "Enter new database password (min 8 characters): " DB_PASSWORD
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
else
    # Use default password
    DB_PASSWORD="$CURRENT_DB_PASSWORD"
fi

# Update password in terraform.tfvars (always, whether changed or default)
if grep -q "^db_password" "$TFVARS_FILE"; then
    # Update existing entry
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^db_password.*|db_password = \"$DB_PASSWORD\"|" "$TFVARS_FILE"
    else
        sed -i "s|^db_password.*|db_password = \"$DB_PASSWORD\"|" "$TFVARS_FILE"
    fi
else
    # Add new entry
    echo "" >> "$TFVARS_FILE"
    echo "# Database Configuration" >> "$TFVARS_FILE"
    echo "db_password = \"$DB_PASSWORD\"" >> "$TFVARS_FILE"
fi

if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo "✅ Database password updated in terraform.tfvars!"
else
    echo "✅ Default password added to terraform.tfvars!"
fi

echo ""
echo "========================================="
echo "  ✅ Setup Complete!"
echo "========================================="
echo ""
echo "📝 Configuration Summary:"
echo "  - SSH Key: $SSH_KEY_PATH"
echo "  - Configuration saved to: terraform.tfvars"
if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo "  - Database password: Custom (updated)"
else
    echo "  - Database password: YourSecurePassword123! (default)"
fi
echo ""
echo "🔒 Security Note:"
echo "  - terraform.tfvars is in .gitignore (won't be committed)"
echo "  - Your sensitive data stays on your machine only"
echo ""
echo "🚀 Next step: Deploy your infrastructure"
echo "   ./scripts/deploy.sh"
echo ""
