#!/usr/bin/env bash
set -euo pipefail

# Initial Setup Script - Run this once before deployment
# Usage: ./scripts/setup.sh

echo "========================================="
echo "  AWS Cloud Final - Initial Setup"
echo "========================================="
echo ""

# Check for existing SSH keys
echo "🔍 Checking for existing SSH keys..."
echo ""

EXISTING_KEYS=()
SSH_DIR="$HOME/.ssh"

if [ -d "$SSH_DIR" ]; then
    # Find all SSH private keys (files with corresponding .pub files)
    while IFS= read -r key; do
        if [ -f "${key}.pub" ]; then
            EXISTING_KEYS+=("$key")
        fi
    done < <(find "$SSH_DIR" -type f -name "id_*" -o -name "*_rsa" -o -name "*-key" | grep -v ".pub")
fi

# Display existing keys if found
if [ ${#EXISTING_KEYS[@]} -gt 0 ]; then
    echo "✅ Found existing SSH key(s):"
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

# Update variables.tf with the SSH key
echo "📝 Updating variables.tf with your SSH key..."

# Create a temporary file with the new content
awk -v new_key="$SSH_PUBLIC_KEY" '
/^variable "ssh_public_key"/ {
    in_var = 1
    print $0
    next
}
in_var && /^  default/ {
    print "  default     = \"" new_key "\""
    in_var = 0
    next
}
in_var && /^}/ {
    in_var = 0
}
!in_var || (in_var && !/^  default/) {
    print $0
}
' variables.tf > variables.tf.tmp && mv variables.tf.tmp variables.tf

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
    
    # Update password in setup-db.sh (if it exists)
    if [ -f "scripts/setup-db.sh" ]; then
        perl -i -pe "s/(mysql.*-p')[^']*(')/\$1$DB_PASSWORD\$2/g" scripts/setup-db.sh
    elif [ -f "scripts/helper/setup-db.sh" ]; then
        perl -i -pe "s/(mysql.*-p')[^']*(')/\$1$DB_PASSWORD\$2/g" scripts/helper/setup-db.sh
    fi
    
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
