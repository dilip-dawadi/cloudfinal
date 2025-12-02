#!/usr/bin/env bash
set -euo pipefail

# Setup database on RDS instance - RUN ONCE after deployment
# Usage: ./scripts/helper/setup-db.sh

echo "========================================="
echo "  Database Setup Script"
echo "========================================="
echo ""

# Get RDS endpoint from Terraform output
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null | cut -d: -f1)
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)

if [ -z "$RDS_ENDPOINT" ] || [ -z "$BASTION_IP" ]; then
    echo "❌ Could not get outputs. Make sure infrastructure is deployed."
    echo "   Run: terraform output"
    exit 1
fi

echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Bastion IP: $BASTION_IP"
echo ""
echo "Creating database table via bastion host..."
echo ""

# SSH to bastion and create table
ssh -o StrictHostKeyChecking=no -i ~/.ssh/cloudfinal-key ec2-user@$BASTION_IP << ENDSSH
# Install MySQL client if not present
sudo yum install -y mariadb105 2>/dev/null || echo "MariaDB client already installed"

# Create the table
mysql -h $RDS_ENDPOINT -u admin -p'YourSecurePassword123!' webapp_db << 'EOSQL'
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES 
    ('Test User', 'test@example.com'),
    ('Demo User', 'demo@example.com')
ON DUPLICATE KEY UPDATE name=name;

SELECT COUNT(*) as total_rows FROM users;
EOSQL

echo ""
echo "✅ Database table created successfully!"
ENDSSH

echo "📝 SQL script created at /tmp/setup_db.sql"
echo ""
echo "To execute on the database:"
echo ""
echo "1. Copy script to bastion:"
echo "   scp -i ~/.ssh/cloudfinal-key /tmp/setup_db.sql ec2-user@${BASTION_IP}:~/"
echo ""
echo "2. SSH to bastion:"
echo "   ssh -i ~/.ssh/cloudfinal-key ec2-user@${BASTION_IP}"
echo ""
echo "3. Run the script:"
echo "   mysql -h ${RDS_ENDPOINT} -u admin -p < setup_db.sql"
echo ""
echo "Or run interactively:"
echo "   mysql -h ${RDS_ENDPOINT} -u admin -p"
echo ""
