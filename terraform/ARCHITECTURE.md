# Architecture Diagram (Text-based)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              Internet                                   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │
                               │ HTTP (Port 80)
                               │
┌──────────────────────────────▼──────────────────────────────────────────┐
│                         AWS Cloud (us-east-1)                           │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    VPC (10.0.0.0/16)                               │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐  │ │
│  │  │           Application Load Balancer                          │  │ │
│  │  │         (student-records-alb)                                │  │ │
│  │  │         Security Group: Allow 80 from 0.0.0.0/0              │  │ │
│  │  └────────────────────┬─────────────┬───────────────────────────┘  │ │
│  │                       │             │                              │ │
│  │  ┌────────────────────┴─────────────┴──────────────────────────┐   │ │
│  │  │                                                             │   │ │
│  │  │  ┌───────────────────────────────────────────────────────┐  │   │ │
│  │  │  │        Availability Zone 1 (us-east-1a)               │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  │  ┌─────────────────────────────────────────────────┐  │  │   │ │
│  │  │  │  │  Public Subnet (10.0.0.0/24)                    │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  │  ┌────────────────────────────────────────────┐ │  │  │   │ │
│  │  │  │  │  │  EC2 Instance (t2.micro)                   │ │  │  │   │ │
│  │  │  │  │  │  - Ubuntu 22.04                            │ │  │  │   │ │
│  │  │  │  │  │  - Node.js Application                     │ │  │  │   │ │
│  │  │  │  │  │  - Auto Scaling Group Member               │ │  │  │   │ │
│  │  │  │  │  │  - IAM Role: LabInstanceProfile            │ │  │  │   │ │
│  │  │  │  │  │  - SG: Allow 80 from ALB                   │ │  │  │   │ │
│  │  │  │  │  └────────────────────────────────────────────┘ │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  └─────────────────────────────────────────────────┘  │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  │  ┌─────────────────────────────────────────────────┐  │  │   │ │
│  │  │  │  │  Private Subnet (10.0.10.0/24)                  │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  │  ┌────────────────────────────────────────────┐ │  │  │   │ │
│  │  │  │  │  │  RDS MySQL (Primary)                       │ │  │  │   │ │
│  │  │  │  │  │  - db.t3.micro                             │ │  │  │   │ │
│  │  │  │  │  │  - MySQL 8.0                               │ │  │  │   │ │
│  │  │  │  │  │  - Database: STUDENTS                      │ │  │  │   │ │
│  │  │  │  │  │  - SG: Allow 3306 from Web Servers         │ │  │  │   │ │
│  │  │  │  │  │  - Not publicly accessible                 │ │  │  │   │ │
│  │  │  │  │  └────────────────────────────────────────────┘ │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  └─────────────────────────────────────────────────┘  │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  └───────────────────────────────────────────────────────┘  │   │ │
│  │  │                                                             │   │ │
│  │  │  ┌───────────────────────────────────────────────────────┐  │   │ │
│  │  │  │        Availability Zone 2 (us-east-1b)               │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  │  ┌─────────────────────────────────────────────────┐  │  │   │ │
│  │  │  │  │  Public Subnet (10.0.1.0/24)                    │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  │  ┌────────────────────────────────────────────┐ │  │  │   │ │
│  │  │  │  │  │  EC2 Instance (t2.micro)                   │ │  │  │   │ │
│  │  │  │  │  │  - Ubuntu 22.04                            │ │  │  │   │ │
│  │  │  │  │  │  - Node.js Application                     │ │  │  │   │ │
│  │  │  │  │  │  - Auto Scaling Group Member               │ │  │  │   │ │
│  │  │  │  │  │  - IAM Role: LabInstanceProfile            │ │  │  │   │ │
│  │  │  │  │  │  - SG: Allow 80 from ALB                   │ │  │  │   │ │
│  │  │  │  │  └────────────────────────────────────────────┘ │  │  │   │ │
│  │  │  │  │                                                 │  │  │   │ │
│  │  │  │  └─────────────────────────────────────────────────┘  │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  │  ┌─────────────────────────────────────────────────┐  │  │   │ │
│  │  │  │  │  Private Subnet (10.0.11.0/24)                  │  │  │   │ │
│  │  │  │  │  (For RDS Multi-AZ - not used)                  │  │  │   │ │
│  │  │  │  └─────────────────────────────────────────────────┘  │  │   │ │
│  │  │  │                                                       │  │   │ │
│  │  │  └───────────────────────────────────────────────────────┘  │   │ │
│  │  │                                                             │   │ │
│  │  └─────────────────────────────────────────────────────────────┘   │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐  │ │
│  │  │                 Internet Gateway                             │  │ │
│  │  └──────────────────────────────────────────────────────────────┘  │ │
│  │                                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                   AWS Managed Services                             │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────┐    ┌───────────────────────────────┐ │ │
│  │  │  AWS Secrets Manager     │    │  Auto Scaling                 │ │ │
│  │  │  - Mydbsecret            │    │  - Min: 2 instances           │ │ │
│  │  │  - DB credentials        │    │  - Max: 4 instances           │ │ │
│  │  │  - Host, user, password  │    │  - Desired: 2                 │ │ │
│  │  │                          │    │  - Policy: Target tracking    │ │ │
│  │  │  Accessed by EC2 via IAM │    │  - Target: 70% CPU            │ │ │
│  │  └──────────────────────────┘    └───────────────────────────────┘ │ │
│  │                                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### Network Layer
- **VPC**: 10.0.0.0/16 (65,536 IPs)
- **Public Subnets**: 10.0.0.0/24, 10.0.1.0/24 (in 2 AZs)
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24 (in 2 AZs)
- **Internet Gateway**: Provides internet access to public subnets
- **Route Tables**: Separate routing for public and private subnets

### Load Balancing Layer
- **Application Load Balancer**: Distributes HTTP traffic across instances
- **Target Group**: Health checks on port 80, 30s interval
- **Listener**: HTTP port 80

### Compute Layer
- **Auto Scaling Group**: 
  - Minimum: 2 instances
  - Maximum: 4 instances
  - Desired: 2 instances
- **Launch Template**: Ubuntu 22.04, t2.micro, userdata script
- **Scaling Policy**: Target tracking based on 70% CPU utilization

### Database Layer
- **RDS MySQL 8.0**: 
  - Instance class: db.t3.micro
  - Storage: 20GB GP3
  - Single-AZ deployment
  - Private subnet only
  - Automated backups enabled

### Security Layer
- **ALB Security Group**: Allows port 80 from internet
- **Web Security Group**: Allows port 80 from ALB only
- **RDS Security Group**: Allows port 3306 from web servers only

### Application Layer
- **Node.js Application**: Student Records management system
- **Database**: MySQL with STUDENTS table
- **Configuration**: Uses Secrets Manager for credentials

### IAM Layer
- **LabRole**: EC2 service role
- **LabInstanceProfile**: Instance profile attached to EC2 instances
- **Permissions**: SecretsManager read access

## Traffic Flow

1. **User Request**: 
   - User → Internet → ALB (Port 80)

2. **Load Distribution**:
   - ALB → Target Group → EC2 Instances (Port 80)

3. **Application Processing**:
   - EC2 retrieves DB credentials from Secrets Manager
   - EC2 connects to RDS MySQL (Port 3306)
   - Application processes request

4. **Response**:
   - EC2 → ALB → Internet → User

## High Availability Features

- **Multi-AZ**: Resources spread across 2 availability zones
- **Load Balancing**: ALB distributes traffic across healthy instances
- **Auto Scaling**: Automatically adds/removes instances based on demand
- **Health Checks**: ALB continuously monitors instance health
- **Database**: RDS with automated backups

## Security Features

- **Network Isolation**: Database in private subnets
- **Security Groups**: Least-privilege access rules
- **Secrets Management**: Credentials stored in AWS Secrets Manager
- **IAM Roles**: EC2 instances use role-based access
- **No Hardcoded Credentials**: All credentials retrieved dynamically

## Scalability Features

- **Horizontal Scaling**: Auto Scaling adds instances under load
- **Load Distribution**: ALB evenly distributes requests
- **Stateless Application**: All state stored in RDS
- **Connection Pooling**: Application uses connection pooling

## Monitoring & Operations

- **CloudWatch Metrics**: CPU, network, request count
- **Auto Scaling Activities**: Logged and viewable
- **ALB Access Logs**: (Can be enabled)
- **RDS Performance Insights**: (Can be enabled)
