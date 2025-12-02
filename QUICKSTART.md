# Quick Start Guide

**Complete deployment in 3 commands!**

## Step 1: Setup (First Time)
```bash
./scripts/setup.sh
```

**Interactive prompts:**
1. Found existing SSH keys? Select one or create new
2. Want to change database password? (optional)

**Duration:** 30 seconds

---

## Step 2: Deploy
```bash
./scripts/deploy.sh
```

**What happens automatically:**
- ✅ Creates VPC with 6 subnets
- ✅ Launches Application Load Balancer
- ✅ Starts Auto Scaling Group (2 instances)
- ✅ Creates RDS MySQL database
- ✅ Sets up security groups
- ✅ Creates database table
- ✅ Instances become healthy

**Duration:** ~10 minutes

---

## Step 3: Access
```bash
./scripts/info.sh
```

Copy the `load_balancer_url` and open in browser!

---

## 🎉 You're Done!

**Try these:**
- Refresh page → see different Instance IDs (load balancing!)
- Add data via form → saved to MySQL
- Check AWS Console → see all resources

## 🧹 Clean Up
```bash
./scripts/destroy.sh
```

Removes everything from AWS.

---

## 📊 Architecture

```
Internet → Load Balancer → [Web Server 1, Web Server 2] → Database
          ↑ Public      ↑ Private App Subnets    ↑ Private DB
```

- **2 Availability Zones** for high availability
- **Auto Scaling:** 2-6 instances based on CPU
- **Secure:** Private subnets, security group chaining
- **Bastion host** for SSH access

## 💡 Tips

- First deployment takes ~10 minutes
- Setup script auto-detects your SSH keys
- Database table created automatically
- All instances become healthy automatically
- See README.md for testing procedures

## ❓ Need Help?

**Instances unhealthy?**
→ Wait 2-3 minutes for initialization

**Can't SSH?**
→ Use bastion host from `info.sh` output

**Want to redeploy?**
→ Just run `deploy.sh` again!
