# Quick Start Guide

## 3-Step Deployment

### Step 1: Setup

```bash
./scripts/setup.sh
```

- Generates SSH key automatically
- Updates configuration
- Prompts for database password

### Step 2: Deploy

```bash
./scripts/deploy.sh
```

- Creates all AWS resources
- Launches instances
- Sets up database automatically

### Step 3: Access

```bash
./scripts/helper/info.sh
```

- Shows load balancer URL
- Shows bastion IP for SSH access

## That's It! 🎉

Open the load balancer URL in your browser. Refresh multiple times to see load balancing in action (different instance IDs).

## Cleanup

```bash
./scripts/destroy.sh
```

## What Gets Created

- VPC with 6 subnets across 2 availability zones
- Application Load Balancer
- Auto Scaling Group (2-6 instances)
- RDS MySQL database
- NAT Gateways, Internet Gateway
- Security groups with proper chaining
- Bastion host for SSH access

## Need Help?

See `README.md` for detailed architecture and demo instructions.
