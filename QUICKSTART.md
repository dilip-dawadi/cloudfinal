# Quick Start

## 1. Setup

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloudfinal-key

# Get public key
cat ~/.ssh/cloudfinal-key.pub
```

## 2. Configure

Edit `variables.tf`:

- Add your SSH public key
- Change database password

## 3. Deploy

```bash
./scripts/deploy.sh
```

## 4. Setup Database

```bash
./scripts/setup-db.sh
```

## 5. Access

```bash
./scripts/info.sh
```

Open the Load Balancer URL in your browser.

## Done! 🎉

See `README.md` for full documentation.
