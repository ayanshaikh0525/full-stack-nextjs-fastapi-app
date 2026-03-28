
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
### Deploy Application to EKS (From Project Repo)

> Repo is already cloned

---

### Step 1: Navigate to Kubernetes Configs

```bash
cd full-stack-nextjs-fastapi-app/fastapi_backend/k8
```
### Step 2: Apply Deployment

```bash
kubectl apply -f deployment.yaml
```
### Step 3: Apply Service
```
kubectl get pods
```

### Apply Service

```
kubectl apply -f service.yaml
```

### Verify 

```
kubectl get svc
```


### Step 4: Install AWS Load Balancer Controller
Associate OIDC Provider

```bash

eksctl utils associate-iam-oidc-provider \
  --region <region> \
  --cluster <cluster-name> \
  --approve
```

Create IAM Policy

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

```

Create Service Account
```
eksctl create iamserviceaccount \
  --cluster <cluster-name> \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

Install via Helm

```
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```
### Step 5: Apply Ingress

```
kubectl apply -f ingress.yaml
```

### Step 6: Access Application
```
kubectl get ingress
```

## Connect Ingress (ALB) to CloudFront (Manual Setup)

After your Ingress creates an AWS ALB, you can attach it to CloudFront.

---

### Step 1: Get Ingress Load Balancer DNS

```bash
kubectl get ingress
```
Example output:
```
NAME        CLASS   HOSTS   ADDRESS
app-ingress         *       abc123.elb.amazonaws.com
```

Copy the ADDRESS (ALB DNS name).

## 🌐 CloudFront Setup for Ingress / Load Balancer

### Step 2: Create CloudFront Distribution
1. Go to **AWS Console**
2. Navigate to **CloudFront**
3. Click on **Create Distribution**

---

### Step 3: Configure Origin
- **Origin Domain Name**  
  - Enter your Load Balancer DNS  
  - Example:
    ```
    abc123.elb.amazonaws.com
    ```

- **Origin Protocol Policy**
  - `HTTP Only` *(default)*  
  - OR `HTTPS Only` *(if your backend supports SSL)*

---

### Step 4: Configure Default Cache Behavior
- **Viewer Protocol Policy**
  - `Redirect HTTP to HTTPS`

- **Allowed HTTP Methods**
  - `GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE`

- **Cache Policy**
  - For APIs → `Caching Disabled`
  - OR use a **custom cache policy** if needed

---

### Step 5: Configure Distribution Settings
- **Price Class**
  - Choose based on your requirement:
    - `Use All Edge Locations` *(best performance)*
    - `Use Only Selected Locations` *(cost optimized)*

---

### Step 6: Create Distribution
1. Click **Create Distribution**
2. Wait for deployment  
   ⏱️ *Usually takes 5–15 minutes*

---

### Step 7: Access Your Application
Once deployed, CloudFront provides a domain like:

```
https://dxxxxx.cloudfront.net
```

## Deploy Frontend to Vercel (Manual Setup)

---

### Step 1: Create New Project

1. Go to Vercel Dashboard
2. Click **Add New → Project**
3. Import your Git repository

---

### Step 2: Configure Project

- **Framework Preset** → Next.js  
- **Root Directory** → `frontend/` *(or your frontend folder name)*  

---

### Step 3: Add Environment Variables

Add required environment variables:

```env
NEXT_PUBLIC_API_URL=https://<your-cloudfront-domain>
OPENAPI_OUTPUT_FILE=openapi.json
```

### Step 4: Deploy
Click Deploy
Wait for build and deployment to complete

### Step 5: Access Application

You will get a Vercel URL like:
```
https://your-project.vercel.app
```
---


# FastAPI + Next.js Jenkins Pipeline Setup

This guide explains how to set up Jenkins for a FastAPI + Next.js project, configure necessary plugins, environment variables, pipeline, and GitHub webhook to automatically trigger builds on code push.

---

## 1. Jenkins Plugins & Environment Variables Setup

Before creating your pipeline, ensure Jenkins has the necessary plugins and environment variables configured.

### Step 1.1: Install Required Plugins

1. Open Jenkins Dashboard → **Manage Jenkins** → **Manage Plugins** → **Available**
2. Search and install:

- **Pipeline**  
- **Docker Pipeline**  
- **GitHub Integration / Git plugin**  
- **Blue Ocean (optional for visual pipelines)**  

3. After installation, **restart Jenkins** if prompted.

### Step 1.2: Configure Environment Variables

1. Go to Jenkins Dashboard → **Manage Jenkins** → **Configure System**
2. Scroll to **Global properties** → check **Environment variables**
3. Add required variables:

```env
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=<your-account-id>
ECR_REPO=<your-ecr-repo>
IMAGE_TAG=<image-tag>
CLUSTER_NAME=<cluster-name>
```

### Save configuration

## Creating a Jenkins Pipeline

This section explains how to create a Jenkins pipeline for your FastAPI + Next.js project, assuming Jenkins, plugins, and environment variables are already configured.

---

### Step 1: Create a New Pipeline Job

1. Open Jenkins Dashboard: `http://<jenkins-ec2-ip>:8080`
2. Click **New Item**
3. Enter **Job Name** → `fastapi-nextjs-pipeline`
4. Select **Pipeline**
5. Click **OK**



### Step 2: Configure Job

#### 2.1 General Section

- (Optional) Add **description**
- Check **Discard old builds** to save space (optional)



#### 2.2 Source Code Management

- Select **Git**
- Repository URL → `<your-repo-url>`
- Branch → `main` (or your branch)
- Credentials → select if your repo is private



#### 2.3 Build Triggers

- Check **GitHub hook trigger for GITScm polling**
  - This will trigger the pipeline whenever a push occurs



#### 2.4 Pipeline Section

- Definition → **Pipeline script from SCM**
- SCM → Git
- Script Path → `fastapi_backend/Jenkinsfile` 

---

### Step 3: Save
Click **Save**

## Configure GitHub Webhook to Trigger Jenkins Pipeline

To make the Jenkins pipeline run automatically on code push, configure a webhook in GitHub.

---

## Configure GitHub Webhook & Trigger Jenkins Pipeline

This section explains how to configure a webhook in GitHub to automatically trigger your Jenkins pipeline when a push occurs.

---

### Step 1: Go to GitHub Repository Settings

1. Open your repository on GitHub
2. Go to **Settings → Webhooks**
3. Click **Add webhook**
4. Configure the webhook:

- **Payload URL** → `http://<jenkins-ec2-public-ip>:8080/github-webhook/`
- **Content type** → `application/json`
- **Events** → Choose **Just the push event**
- Click **Add webhook**

---

### Step 2: Trigger Jenkins via Minor Change

1. Navigate to your backend folder:

```bash
cd full-stack-nextjs-fastapi-app/fastapi_backend
```

2. Create or update a dummy file to generate a change:
```
echo "trigger webhook" >> .trigger
```

3. Stage and commit the change:
```
git add .
git commit -m "Do minor change in fastapi_backend to trigger Jenkins"
```

4. Push the change to the main branch:
```
git push origin main
```

### Step 3: Verify Jenkins Build

After pushing the change to GitHub:

1. Go to Jenkins Dashboard → **Your Pipeline Job**
2. Click on **Build History**
3. You should see a new build triggered automatically

**Note:** This confirms that the GitHub webhook is correctly configured and your Jenkins pipeline is working as expected.


#### Project Structure

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
