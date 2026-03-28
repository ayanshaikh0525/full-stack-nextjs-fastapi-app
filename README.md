
<a href="https://www.vintasoftware.com/blog/next-js-fastapi-template"><img src="docs/images/banner.png" alt="Next.js FastAPI Template" width="auto"></a>

# Next.js FastAPI Template

## Overview

Full-stack production-ready template using:

* FastAPI (Python backend)
* Next.js (frontend)
* AWS EKS (Kubernetes)
* RDS (PostgreSQL)
* ECR (Docker registry)
* Jenkins (CI/CD)
* Terraform (Infrastructure as Code)

---

## Architecture

```
User → Vercel (Next.js)
            ↓
        API Calls
            ↓
     AWS LoadBalancer
            ↓
         EKS Cluster
            ↓
        FastAPI Pods
            ↓
         RDS
```

---

## Prerequisites

* AWS account
* Terraform
* Docker
* kubectl
* Node.js
* Python
* Jenkins
* Vercel

---

## Setup

## Configure AWS CLI (Required for Terraform)

Before running Terraform, configure AWS CLI with proper credentials.

---

### Step 1: Install AWS CLI

```bash
# Linux / Mac
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

```

### Step 2: Configure AWS Credentials
```bash
aws configure
```

Enter the following:
```
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: us-east-1
Default output format: json
```

## Generate SSH Key for Bastion Host

Before running `terraform apply`, create an SSH key pair for EC2 access.

### Step 1: Generate Key

```bash
ssh-keygen -t rsa -b 4096 -C "example.com"

```

### Step 2: Save Key
Press Enter to save at default location: ~/.ssh/id_rsa
Optionally set a passphrase

This creates:
```bash
~/.ssh/id_rsa        # Private key
~/.ssh/id_rsa.pub    # Public key
```

### Infrastructure



```bash
cd terraform/environments/dev
terraform init
terraform apply -auto-approve
```

### Build & Push Backend - (We will Just do this once - later it will get automated through Jenkins)

```bash
docker build -t fastapi-backend .
docker tag fastapi-backend:latest <ecr-repo>
docker push <ecr-repo>
```

### SSH into Bastion Host and Connect to EKS

#### Prerequisites

- Bastion public IP
- SSH private key (`.pem` or `id_rsa`)
---

#### Step 1: Set Key Permission (Local Machine)

```bash
chmod 400 <key-name>.pem
```

#### Step 2: SSH into Bastion Host
```
ssh -i <key-name>.pem ubuntu@<bastion-public-ip>
```



### Configure EKS

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### Deploy to Kubernetes

```bash
kubectl apply -f k8s/
```

### Deploy Frontend

```bash
vercel --prod
```

---

## Environment Variables

```
NEXT_PUBLIC_API_URL=http://<load-balancer-url>
```

---

## Project Structure

```
.
├── backend/
├── frontend/
├── terraform/
├── k8s/
└── Jenkinsfile
```

---

## One Command Setup

```bash
terraform init && terraform apply -auto-approve
```

---

## Notes

* RDS should be private
* Security groups must allow EKS access
* Use bastion for DB debugging

---

## License

MIT
