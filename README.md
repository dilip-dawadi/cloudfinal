# AWS Multi-Tier Web Application

Fully automated Terraform deployment of a highly available, scalable web application on AWS.

## 🚀 Quick Start

### 1. Initial Setup (One Command!)

```bash
./scripts/setup.sh
```

Automatically generates SSH key, updates configuration, and prompts for database password.

### 2. Deploy Infrastructure

```bash
./scripts/deploy.sh
```

Deploys everything and creates database table automatically - **no manual steps required!**

### 3. Access Application

```bash
./scripts/helper/info.sh
```

Get your load balancer URL and other deployment information.

### 4. Clean Up

```bash
./scripts/destroy.sh
```

## 📁 Project Structure

```
├── network/      - VPC, Subnets, NAT Gateways, Internet Gateway
├── security/     - Security Groups (ALB, Web, Bastion, Database)
├── alb/          - Application Load Balancer, Target Group
├── web/          - Launch Template, Bastion Host
├── asg/          - Auto Scaling Group, Scaling Policies
├── database/     - RDS MySQL Database
└── scripts/      - Automation scripts (setup, deploy, info, destroy)
```

## 🏗️ AWS Infrastructure

**Network Layer**

- VPC: 192.168.0.0/16 across 2 Availability Zones
- 2 Public Subnets: 192.168.1.0/24, 192.168.2.0/24
- 2 Private App Subnets: 192.168.3.0/24, 192.168.4.0/24
- 2 Private DB Subnets: 192.168.5.0/24, 192.168.6.0/24
- 2 NAT Gateways (one per AZ)
- Internet Gateway

**Compute Layer**

- Application Load Balancer (public-facing)
- Auto Scaling Group: Min=2, Desired=2, Max=6
- Launch Template with Amazon Linux 2023
- CPU-based scaling (70% scale up, 20% scale down)

**Database Layer**

- RDS MySQL (db.t3.micro)
- Multi-AZ capable
- Private subnets only

**Security Layer**

- Security group chaining: ALB → Web → Database
- Bastion host for SSH access
- No direct internet access to app/database instances

## 🎯 Video Demo Requirements

1. **Show Components**: Load Balancer, Auto Scaling Group, Target Group, NAT Gateways, Database, Launch Template, Security Group Chain

2. **Load Balancing Test**: Refresh browser to see different Instance IDs

3. **Database Operations**: Insert data from each instance

   ```sql
   SELECT * FROM users ORDER BY created_at DESC;
   ```

4. **Auto Scaling Test**:

   ```bash
   # SSH to instance and run CPU stress
   while true; do true; done
   # Watch instances scale from 2 to 6
   ```

5. **High Availability Test**: Terminate all instances → ASG recovers with 2 instances (min_size)

## 📚 Additional Documentation

- `QUICKSTART.md` - Simplified deployment guide
