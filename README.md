# AWS Highly Available Student Records Web Application

A production-ready, highly available, and auto-scaling web application infrastructure deployed on AWS using Terraform. Built for AWS Academy Cloud Architecture capstone project.

## 🏗️ Architecture

- **Multi-AZ VPC** with public/private subnets across 2 availability zones
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** (2-4 EC2 t2.micro instances) with CPU-based scaling
- **RDS MySQL** database in private subnets (single-AZ)
- **AWS Secrets Manager** for secure credential management
- **Security Groups** with least-privilege access control

## 📋 Prerequisites

- AWS Account (AWS Academy Lab environment)
- Terraform >= 1.0
- AWS CLI configured with credentials
- `LabRole` and `LabInstanceProfile` IAM roles (pre-existing in AWS Academy)

## 🚀 Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/deviant101/aws-scalable-web-app-terraform.git
cd aws-scalable-web-app-terraform
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (us-east-1)
# OR
# You can get credentials directly from AWS Details section of the Lab
```

### 3. Customize Variables (Optional)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit values as needed
```

### 4. Deploy Infrastructure

**Option A: Using Automated Script (Recommended)**

```bash
cd terraform
./deploy.sh
```

The script will:
- ✅ Check prerequisites (Terraform, AWS CLI)
- ✅ Validate AWS credentials
- ✅ Initialize Terraform
- ✅ Create deployment plan
- ✅ Deploy infrastructure (~10-15 minutes)
- ✅ Display application URL and outputs


**Option B: Manual Deployment**

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
# Type 'yes' when prompted
```

### 5. Access Your Application

After deployment, get your application URL:

```bash
terraform output alb_url
# Output: http://student-records-alb-XXXXXXXXX.us-east-1.elb.amazonaws.com
```

**Wait 5-7 minutes** for instances to initialize, then open the URL in your browser.

## 📁 Project Structure

```
├── terraform/
│   ├── main.tf              # Provider & AMI configuration
│   ├── vpc.tf               # VPC, subnets, IGW, route tables
│   ├── security_groups.tf   # Security groups for ALB, EC2, RDS
│   ├── rds.tf               # RDS MySQL database
│   ├── secrets.tf           # Secrets Manager for DB credentials
│   ├── alb.tf               # Application Load Balancer
│   ├── autoscaling.tf       # Launch template & Auto Scaling
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── deploy.sh            # Automated deployment script
└── UserdataScript-phase-3.sh  # EC2 initialization script
```

## ⚙️ Configuration

Key variables in `terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
project_name         = "student-records"
instance_type        = "t2.micro"
db_instance_class    = "db.t3.micro"
asg_min_size         = 2
asg_max_size         = 4
asg_desired_capacity = 2
cpu_target_value     = 70.0  # Auto-scaling threshold

## 🧪 Testing

```bash
# Install loadtest globally
npm install -g loadtest

# Run load test (replace with your ALB URL)
loadtest --rps 1000 -c 500 -k <YOUR_ALB_URL>
```

Watch Auto Scaling in action:
```bash
# Monitor target health
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN>

# Check Auto Scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name student-records-asg
```

## 🔒 Security Features
Watch Auto Scaling in action:
```bash
# Monitor target health
## 🔒 Security Features

- ✅ Database in private subnets (no public access)
- ✅ Security group isolation (ALB → EC2 → RDS)
- ✅ Credentials stored in AWS Secrets Manager
- ✅ IAM roles for secure service-to-service communication
- ✅ Least-privilege access controls

## 💰 Cost Optimization

- t2.micro EC2 instances (free tier eligible)
- db.t3.micro RDS instance
- Single-AZ database deployment
- Auto Scaling matches actual demand
- Estimated cost: **~$30-50/month**

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
cd terraform
terraform destroy
# Type 'yes' to confirm
```

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## 🐛 Troubleshooting

**502 Bad Gateway / Unhealthy Targets:**
- Wait 5-7 minutes for instances to fully initialize
- Check logs: `aws ssm send-command --instance-ids <ID> --document-name "AWS-RunShellScript" --parameters 'commands=["tail -100 /var/log/user-data.log"]'`

**LabInstanceProfile not found:**
- Uncomment IAM role resources in `autoscaling.tf` (lines 6-37)
- Or ensure LabRole exists in your AWS Academy account

**Database connection errors:**
- Verify Secrets Manager contains correct RDS endpoint
- Check security group allows port 3306 from web servers to RDS

## 📚 Resources

- [AWS Academy Cloud Architecture](https://aws.amazon.com/training/awsacademy/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 📝 License

This project is created for educational purposes as part of AWS Academy coursework.

## 👤 Author

**deviant101** - [GitHub](https://github.com/deviant101)

---

⭐ Star this repo if you found it helpful!