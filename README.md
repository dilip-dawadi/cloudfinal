# AWS Multi-Tier Web Application

Automated Terraform infrastructure for a highly available, auto-scaling web application on AWS. Perfect for learning cloud architecture!

## ⚡ 3 Steps to Deploy

### Step 1: Setup (First Time Only)

```bash
./scripts/setup.sh
```

**What it does:**

- 🔍 Finds your existing SSH keys automatically
- 🔑 Or creates a new one if needed
- ⚙️ Updates configuration automatically
- 🔐 Optional: Set custom database password

### 🔒 Security Best Practice (IMPORTANT!)

**Default values** in `variables.tf` work out of the box, but for **security**, create a `terraform.tfvars` file to override sensitive defaults:

**Create the file:**

```bash
nano terraform.tfvars
```

**Add your secure values:**

```hcl
# Database Configuration
db_password = "YourSecurePassword123!"  # Min 8 characters - CHANGE THIS!
db_username = "admin"
db_name = "webapp_db"
db_table_name = "users"

# SSH Key (setup.sh updates this automatically)
ssh_public_key = "ssh-rsa AAAA...your-actual-key..."
```

**Why this matters:**

- ✅ `terraform.tfvars` is in `.gitignore` - won't be committed to git
- ✅ Keeps passwords and keys out of version control
- ✅ Your secrets stay on your machine only
- ✅ Values here **override** defaults in `variables.tf`

**What to customize:**

- `db_password` - Use a strong password (minimum 8 characters)
- `db_username`, `db_name`, `db_table_name` - Optional, defaults work fine
- `ssh_public_key` - `setup.sh` handles this automatically

> 💡 **Tip:** The `setup.sh` script will update your SSH key automatically, so you only need to manually set the database password if you want something different than the default.

### Step 2: Deploy

```bash
./scripts/deploy.sh
```

**What happens:**

- 🏗️ Creates VPC, subnets, load balancer, auto-scaling group
- 💾 Launches RDS MySQL database
- 🖥️ Starts 2 web servers automatically
- ✅ Instances become healthy automatically
- 🌐 Shows you the website URL

**Deploy time:** ~10 minutes

### Step 3: Open Your Website

```bash
./scripts/info.sh
```

Copy the `load_balancer_url` and open it in your browser!

**Refresh the page** → See different server IDs (load balancing in action!)

## 🎓 What You'll Learn

This project demonstrates:

- ✅ **Multi-tier architecture** (web, app, database layers)
- ✅ **High availability** (2 availability zones)
- ✅ **Auto scaling** (2-6 instances based on CPU)
- ✅ **Load balancing** (distributes traffic)
- ✅ **Network security** (public/private subnets, security groups)
- ✅ **Infrastructure as Code** (Terraform)

## 📋 What Gets Created

```
Internet
    ↓
Application Load Balancer (public)
    ↓
Auto Scaling Group (private subnets)
├── Web Server 1 (AZ-A)
├── Web Server 2 (AZ-B)
└── ... up to 6 servers
    ↓
RDS MySQL Database (private subnets)
```

**Components:**

- 1 VPC with 6 subnets across 2 availability zones
- 1 Internet Gateway + 2 NAT Gateways
- 1 Application Load Balancer
- 2-6 EC2 instances (auto-scaling)
- 1 RDS MySQL database
- 1 Bastion host for SSH access
- Security groups with proper chaining

## 🧪 Test It Out

### Test 1: Load Balancing

Refresh your browser multiple times → different `Instance ID` appears each time

### Test 2: Database

Add users through the web form → data saved to MySQL → visible from all servers

### Test 3: Auto Scaling

```bash
# SSH to any instance
ssh -i ~/.ssh/your-key ec2-user@instance-ip

# Run CPU stress test
while true; do true; done
```

Watch in AWS Console: Instances scale from 2 → 6!

### Test 4: High Availability

Terminate all instances in AWS Console → Auto Scaling Group automatically launches 2 new ones!

## 🗂️ Project Structure

```
cloudfinal/
├── scripts/
│   ├── setup.sh ........... One-time setup (SSH key)
│   ├── deploy.sh .......... Deploy everything
│   ├── info.sh ............ Show URLs and IPs
│   └── destroy.sh ......... Clean up all resources
├── network/ ............... VPC, subnets, gateways
├── security/ .............. Security groups
├── alb/ ................... Load balancer
├── web/ ................... EC2 launch template
├── asg/ ................... Auto scaling configuration
└── database/ .............. RDS MySQL
```

## 🧹 Clean Up

```bash
./scripts/destroy.sh
```

Removes all AWS resources to avoid charges.

## 📚 Additional Resources

- `QUICKSTART.md` - Simplified step-by-step guide
- AWS Console - See all resources visually

## ❓ Troubleshooting

**Problem:** Target group shows unhealthy
**Solution:** Wait 2-3 minutes for database table creation

**Problem:** Can't connect to instances
**Solution:** Use bastion host: `ssh -i ~/.ssh/your-key ec2-user@bastion-ip`

**Problem:** Website not loading
**Solution:** Check security groups allow HTTP (port 80)

## 💡 Pro Tips

- **First deployment?** Takes ~10 minutes
- **Subsequent deploys?** Use `./scripts/deploy.sh` anytime
- **Cost saving:** Run `./scripts/destroy.sh` when not using it
- **SSH key:** Setup script auto-detects existing keys
- **Database:** Table created automatically, no manual steps!

## 📚 Additional Documentation

- `QUICKSTART.md` - Simplified deployment guide
