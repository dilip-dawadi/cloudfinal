# Quick Deployment Guide

## 1. Setup SSH Key

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloudfinal-key
cat ~/.ssh/cloudfinal-key.pub
```

## 2. Configure Variables

Edit `variables.tf`:

- Paste your SSH public key in `ssh_public_key`
- Change `db_password`

## 3. Deploy

```bash
# Easy way (recommended)
./scripts/deploy.sh

# Or manually
terraform init
terraform plan
terraform apply
```

## 4. Create Database Table

```bash
# Get outputs
terraform output

# SSH to bastion
ssh -i ~/.ssh/cloudfinal-key ec2-user@<BASTION_IP>

# Connect to MySQL
mysql -h <RDS_ENDPOINT> -u admin -p
```

```sql
USE webapp_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5. Access Application

Open: `http://<LOAD_BALANCER_DNS>`

## 6. Test Auto Scaling

```bash
# SSH to bastion, then to app server
ssh ec2-user@<PRIVATE_IP>

# Run CPU stress
while true; do true; done
```

Watch ASG scale to 6 instances.

## 7. Get Deployment Info

```bash
./scripts/info.sh
```

## 8. Cleanup

```bash
./scripts/destroy.sh
```
