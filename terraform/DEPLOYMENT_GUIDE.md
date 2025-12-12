# AWS Student Records Application - Deployment Guide

## Complete Step-by-Step Deployment

This guide walks you through deploying the complete infrastructure for the Student Records web application using Terraform.

---

## Prerequisites Checklist

- [ ] AWS Academy Lab environment access
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (version >= 1.0)
- [ ] Git installed
- [ ] Access to AWS Console

---

## Phase 1: Planning (No AWS resources needed)

### Step 1.1: Review Architecture

The Terraform code creates:
- VPC with public/private subnets in 2 AZs
- Internet Gateway and route tables
- Application Load Balancer (ALB)
- Auto Scaling Group with 2-4 EC2 instances
- RDS MySQL database
- Security groups for ALB, EC2, and RDS
- Secrets Manager for database credentials

### Step 1.2: Estimate Costs

Use AWS Pricing Calculator for us-east-1:
- 2x t2.micro EC2 instances (Auto Scaling)
- 1x db.t3.micro RDS instance
- 1x Application Load Balancer
- Data transfer and storage

Expected monthly cost: ~$30-50 (with free tier benefits)

---

## Phase 2 & 3: Infrastructure Deployment

### Step 2.1: Prepare Terraform Configuration

```bash
# Navigate to terraform directory
cd /home/deviant/Uni/Cloud-Comp/Project/terraform

# Create terraform.tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your preferences (optional)
nano terraform.tfvars
```

### Step 2.2: Initialize Terraform

```bash
# Initialize Terraform (downloads AWS provider)
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

### Step 2.3: Validate Configuration

```bash
# Validate the configuration
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 2.4: Review Deployment Plan

```bash
# Create and review execution plan
terraform plan
```

Review the output to see:
- Resources to be created (~30-40 resources)
- Estimated changes
- No errors

### Step 2.5: Deploy Infrastructure

```bash
# Apply the configuration
terraform apply
```

When prompted:
1. Review the plan
2. Type `yes` to confirm
3. Wait 10-15 minutes for deployment

Expected output:
```
Apply complete! Resources: 35 added, 0 changed, 0 destroyed.

Outputs:
alb_url = "http://student-records-alb-1234567890.us-east-1.elb.amazonaws.com"
rds_endpoint = "student-records-db.abc123.us-east-1.rds.amazonaws.com:3306"
...
```

### Step 2.6: Save Important Outputs

```bash
# Save all outputs to a file
terraform output > deployment-outputs.txt

# Get the application URL
terraform output alb_url
```

---

## Phase 3: Database and Application Setup

### Step 3.1: Wait for Application to Initialize

After deployment:
1. Wait 5-10 minutes for:
   - RDS database to become available
   - EC2 instances to launch and run user data script
   - Application to download and install
   - ALB health checks to pass

### Step 3.2: Verify Deployment

```bash
# Get the load balancer URL
ALB_URL=$(terraform output -raw alb_url)
echo "Application URL: $ALB_URL"

# Test the application
curl -I $ALB_URL
```

Expected response:
```
HTTP/1.1 200 OK
```

### Step 3.3: Access the Web Application

1. Open browser
2. Navigate to the ALB URL from output
3. You should see the Student Records application
4. Test functionality:
   - View existing records (will be empty initially)
   - Add a new student record
   - Edit a record
   - Delete a record

---

## Phase 4: Load Testing and Auto Scaling

### Step 4.1: Set Up AWS Cloud9 (Optional)

If you want to run load tests from AWS environment:

1. Go to AWS Console → Cloud9
2. Create new environment:
   - Name: `student-records-testing`
   - Instance type: `t3.micro`
   - Platform: `Amazon Linux 2`
3. Open the Cloud9 IDE

### Step 4.2: Install Load Testing Tool

```bash
# In Cloud9 terminal or your local terminal
npm install -g loadtest
```

### Step 4.3: Run Load Test

```bash
# Replace with your ALB URL
ALB_URL="http://student-records-alb-1234567890.us-east-1.elb.amazonaws.com"

# Run load test
loadtest --rps 1000 -c 500 -k $ALB_URL
```

Press `Ctrl+C` to stop the test.

### Step 4.4: Monitor Auto Scaling

1. Go to AWS Console → EC2 → Auto Scaling Groups
2. Select your Auto Scaling Group
3. Click "Activity" tab to see scaling activities
4. Click "Monitoring" tab to see metrics

During load test, you should see:
- CPU utilization increase
- New instances launching when CPU > 70%
- Instances terminating when load decreases

---

## Monitoring and Management

### View Infrastructure State

```bash
# List all resources
terraform state list

# Show specific resource details
terraform state show aws_lb.main
```

### Access Secrets Manager

```bash
# Get secret ARN
terraform output secret_arn

# View secret (from AWS CLI)
aws secretsmanager get-secret-value --secret-id Mydbsecret
```

### Check Auto Scaling Activity

```bash
# Get ASG name
ASG_NAME=$(terraform output -raw autoscaling_group_name)

# Describe Auto Scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name $ASG_NAME
```

### View RDS Database

```bash
# Get RDS endpoint
terraform output rds_endpoint

# Connect to RDS (requires mysql client and access from security group)
# Note: Direct connection requires you to be in the VPC or modify security group
```

---

## Troubleshooting

### Issue 1: LabInstanceProfile Not Found

**Error:** `Error creating Launch Template: InvalidParameterValue: Value (LabInstanceProfile) for parameter iamInstanceProfile is invalid`

**Solution:**
1. Open `terraform/autoscaling.tf`
2. Uncomment the IAM role and instance profile resources
3. Run `terraform apply` again

### Issue 2: Application Not Loading

**Symptoms:** ALB URL returns 503 or timeout

**Checks:**
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# Check Auto Scaling instances
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $(terraform output -raw autoscaling_group_name)
```

**Solutions:**
- Wait longer (application startup takes 5-10 minutes)
- Check EC2 instance logs in AWS Console
- Verify security group rules allow traffic
- Check user data script execution

### Issue 3: Database Connection Errors

**Symptoms:** Application loads but can't fetch/save data

**Checks:**
```bash
# Verify Secrets Manager secret
aws secretsmanager get-secret-value --secret-id Mydbsecret

# Check RDS status
aws rds describe-db-instances --db-instance-identifier student-records-db
```

**Solutions:**
- Verify RDS is in "available" state
- Check RDS security group allows port 3306 from web servers
- Verify secret contains correct endpoint

### Issue 4: Terraform State Lock

**Error:** `Error acquiring state lock`

**Solution:**
```bash
# Force unlock (use the Lock ID from error message)
terraform force-unlock <LOCK_ID>
```

---

## Making Changes

### Update Configuration

```bash
# Edit any .tf file
nano variables.tf

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Scale Application

```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Change these values:
# asg_min_size = 3
# asg_max_size = 6
# asg_desired_capacity = 3

# Apply changes
terraform apply
```

---

## Cleanup

### Destroy All Resources

**WARNING:** This will delete everything including the database!

```bash
# Destroy all resources
terraform destroy
```

When prompted:
1. Type `yes` to confirm
2. Wait 10-15 minutes for deletion

### Verify Cleanup

```bash
# Check for remaining resources in AWS Console:
# - EC2 → Instances
# - RDS → Databases
# - VPC → Your VPCs
# - EC2 → Load Balancers
```

---

## Cost Management

### Monitor Costs

1. AWS Console → Billing Dashboard
2. AWS Cost Explorer
3. Check daily usage

### Cost Optimization Tips

- Stop/destroy resources when not in use
- Use AWS Academy credits
- Monitor Auto Scaling (ensure instances terminate after load tests)
- Use smaller instance types if acceptable
- Delete unnecessary snapshots

---

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Academy Resources](https://aws.amazon.com/training/awsacademy/)

---

## Support

For issues with:
- **Terraform code:** Review this documentation and Terraform AWS provider docs
- **AWS Academy lab:** Contact your instructor or AWS Academy support
- **AWS services:** Check AWS documentation and service health dashboard

---

## Summary of Commands

```bash
# Initial setup
cd terraform
terraform init
terraform validate
terraform plan

# Deploy
terraform apply

# Get outputs
terraform output
terraform output alb_url

# Load test
npm install -g loadtest
loadtest --rps 1000 -c 500 -k http://<ALB-URL>

# Monitor
terraform state list
aws autoscaling describe-scaling-activities --auto-scaling-group-name <ASG-NAME>

# Cleanup
terraform destroy
```

---

Good luck with your project! 🚀
