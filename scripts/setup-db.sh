#!/usr/bin/env bash
set -euo pipefail

# Setup database on RDS instance
# Usage: ./scripts/setup-db.sh

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

# Create SQL script
cat > /tmp/setup_db.sql << 'EOF'
USE webapp_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_email (email)
);

-- Show table structure
DESCRIBE users;

-- Insert sample data
INSERT INTO users (name, email) VALUES 
    ('Test User 1', 'test1@example.com'),
    ('Test User 2', 'test2@example.com');

-- Verify
SELECT * FROM users;
SELECT COUNT(*) as total_users FROM users;
EOF

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
