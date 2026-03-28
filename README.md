
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

### Infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### Configure EKS

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### Build & Push Backend

```bash
docker build -t fastapi-backend .
docker tag fastapi-backend:latest <ecr-repo>
docker push <ecr-repo>
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
