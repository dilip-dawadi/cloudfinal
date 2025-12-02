# AWS Cloud Final Project - Terraform

Multi-tier web application infrastructure matching the AWS architecture diagram.

## 📁 Project Structure (Layer-Based)

```
network/      - VPC, Subnets, NAT Gateways, Routes
security/     - Security Groups (ALB, Web, Bastion, Database)
alb/          - Application Load Balancer, Target Group
web/          - Launch Template, Bastion Host
asg/          - Auto Scaling Group, Scaling Policies
database/     - RDS MySQL Instance
```

Each folder contains: `main.tf`, `variables.tf`, `outputs.tf`

## Quick Deploy

### 1. Setup SSH Key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloudfinal-key
cat ~/.ssh/cloudfinal-key.pub
```

### 2. Configure
Edit `variables.tf`:
- Add your SSH public key
- Change database password

### 3. Deploy
```bash
./scripts/deploy.sh
```

### 4. Create Database Table
```bash
./scripts/setup-db.sh
```

### 5. Access
```bash
./scripts/info.sh
```

## Architecture Matches Diagram

✅ **Network Layer**
- VPC: 192.168.0.0/16
- Availability Zones: A & B
- Public Subnets: 192.168.1.0/24, 192.168.2.0/24
- Private Subnets (App): 192.168.3.0/24, 192.168.4.0/24
- Private Subnets (DB): 192.168.5.0/24, 192.168.6.0/24
- NAT Gateways: 2 (one per AZ)
- Internet Gateway: 1

✅ **Security Layer**
- Security group chaining for database
- ALB → Web → Database access control

✅ **ALB Layer**
- Application-tier load balancer
- Target group with health checks

✅ **Web Layer**
- Launch template with user data
- Bastion host in public subnet

✅ **ASG Layer**
- Min=2, Desired=2, Max=6
- CPU-based scaling (70% up, 20% down)

✅ **Database Layer**
- RDS MySQL in private subnets
- Primary DB instance

## Project Deliverables

### 1. Show Components
- Load Balancer
- Auto Scaling Group (min=2, max=6)
- Target Group
- NAT Gateways (2)
- Route Tables
- RDS Database
- Launch Template
- Security Group Chain

### 2. Demonstrate

**Load Balancing:**
```bash
# Refresh browser, see different instance IDs
```

**Database:**
```sql
SELECT * FROM users ORDER BY created_at DESC;
```

**Auto Scaling:**
```bash
# SSH to instance
while true; do true; done
# Watch scale to 6
```

**High Availability:**
```bash
# Terminate all instances
# ASG recovers with 2 instances (min_size)
```

## Scripts

```bash
./scripts/deploy.sh    # Deploy infrastructure
./scripts/plan.sh      # Preview changes
./scripts/info.sh      # Show deployment info
./scripts/setup-db.sh  # Database setup helper
./scripts/destroy.sh   # Destroy infrastructure
```

## Troubleshooting

**Website not loading?**
- Check target group health
- Verify security groups

**Database connection error?**
- Verify RDS status
- Check security group rules

**Auto scaling not working?**
- Check CloudWatch alarms
- Verify scaling policies

## Cleanup

```bash
./scripts/destroy.sh
```

## Documentation

- `QUICKSTART.md` - Quick deployment guide
- `DEPLOY.md` - Step-by-step deployment
- `SQL_COMMANDS.md` - Database reference
