#!/bin/bash
# Quick Start Script for Student Records Application Deployment

set -e

echo "=================================="
echo "Student Records App - Quick Deploy"
echo "=================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform is not installed${NC}"
    echo "Please install Terraform from: https://www.terraform.io/downloads"
    exit 1
fi
echo -e "${GREEN}✓ Terraform found: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI is not installed${NC}"
    echo "Please install AWS CLI from: https://aws.amazon.com/cli/"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI found${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}ERROR: AWS credentials not configured${NC}"
    echo "Please configure AWS CLI with: aws configure"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials configured${NC}"

echo ""
echo -e "${YELLOW}Current AWS Account:${NC}"
aws sts get-caller-identity

echo ""
read -p "Continue with deployment? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Navigate to terraform directory
cd "$(dirname "$0")"

# Create terraform.tfvars if it doesn't exist
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${GREEN}✓ Created terraform.tfvars${NC}"
    echo -e "${YELLOW}You can edit terraform.tfvars to customize settings${NC}"
    echo ""
fi

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init
echo -e "${GREEN}✓ Terraform initialized${NC}"
echo ""

# Validate configuration
echo -e "${YELLOW}Validating configuration...${NC}"
terraform validate
echo -e "${GREEN}✓ Configuration valid${NC}"
echo ""

# Create plan
echo -e "${YELLOW}Creating deployment plan...${NC}"
terraform plan -out=tfplan
echo -e "${GREEN}✓ Plan created${NC}"
echo ""

# Apply
echo -e "${YELLOW}Starting deployment...${NC}"
echo "This will take approximately 10-15 minutes"
echo ""

if terraform apply tfplan; then
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Deployment successful!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    
    # Display outputs
    echo -e "${YELLOW}Important information:${NC}"
    echo ""
    
    ALB_URL=$(terraform output -raw alb_url 2>/dev/null || echo "Not available")
    RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null || echo "Not available")
    
    echo -e "${GREEN}Application URL:${NC} $ALB_URL"
    echo -e "${GREEN}Database Endpoint:${NC} $RDS_ENDPOINT"
    echo ""
    
    # Save outputs
    terraform output > deployment-outputs.txt
    echo -e "${GREEN}✓ Outputs saved to deployment-outputs.txt${NC}"
    echo ""
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Wait 5-10 minutes for the application to fully initialize"
    echo "2. Open the Application URL in your browser"
    echo "3. Test the student records functionality"
    echo ""
    echo -e "${YELLOW}To test auto-scaling:${NC}"
    echo "npm install -g loadtest"
    echo "loadtest --rps 1000 -c 500 -k $ALB_URL"
    echo ""
    echo -e "${YELLOW}To destroy all resources:${NC}"
    echo "terraform destroy"
    echo ""
    
else
    echo -e "${RED}Deployment failed!${NC}"
    echo "Check the error messages above"
    exit 1
fi
