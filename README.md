# AWS Solutions Architect Terraform Infrastructure

Production-ready Infrastructure-as-Code for the 12-week AWS Solutions Architect Professional exam learning roadmap. Deploy a complete 3-tier microservices architecture on AWS with Terraform.

## 📋 Architecture Overview

This Terraform configuration deploys a complete AWS infrastructure supporting the exam preparation curriculum:

```
┌─────────────────────────────────────────────┐
│        Application Load Balancer            │
│     (Public - Multi-AZ HA)                  │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
┌──────▼──────┐   ┌──────▼──────┐
│   EC2/ECS   │   │   ElastiCache│
│  (Private)  │   │   (Redis)    │
└──────┬──────┘   └──────┬──────┘
       │                 │
       │    ┌────────────┘
       │    │
┌──────▼────▼──────┐
│   RDS PostgreSQL │
│  (Multi-AZ)      │
└──────────────────┘

Security Foundation:
- VPC with public/private subnets across 2 AZs
- Security groups per tier (ALB, App, DB)
- KMS encryption (at-rest)
- TLS encryption (in-transit)
- Secrets Manager (passwords, JWT keys)
- CloudTrail audit logging
- IAM roles with least privilege
```

## 🚀 Quick Start

### Prerequisites

- AWS account with credentials configured
- Terraform >= 1.0
- Terraform Cloud account (recommended) or local state

### Setup

1. **Clone and initialize:**
   ```bash
   cd /Users/kkondoju/aws-solution-architect-terraform
   terraform init
   ```

2. **Update configuration:**
   ```bash
   # Edit terraform.tfvars
   vi terraform.tfvars
   ```

3. **Configure required values:**
   - `db_password` — PostgreSQL admin password (32+ chars recommended)
   - `jwt_secret` — JWT signing key (64+ chars recommended)
   - `key_pair_name` — Your EC2 key pair in the target region

4. **Review the plan:**
   ```bash
   terraform plan -out=tfplan
   ```

5. **Deploy:**
   ```bash
   terraform apply tfplan
   ```

## 📦 Modules

### 1. VPC Module (`modules/vpc/`)
**Multi-AZ networking foundation**

- VPC with configurable CIDR
- 3 public subnets (ALB, NAT gateway)
- 2 private subnets (App tier)
- 2 private subnets (Database tier)
- Internet Gateway, NAT Gateway, route tables
- Security groups:
  - `alb_security_group` — Port 80/443 from anywhere
  - `app_security_group` — App port from ALB
  - `db_security_group` — Port 5432 from app subnet

**Outputs:**
- VPC ID, subnet IDs, security group IDs
- Route table IDs

**Enable/Disable:** `enable_services.vpc = true/false`

---

### 2. RDS Module (`modules/rds/`)
**PostgreSQL database with High Availability**

- PostgreSQL 14.9 (configurable)
- Multi-AZ deployment with automatic failover
- Automated daily backups (7-day retention, configurable)
- Enhanced monitoring via CloudWatch
- Parameter group with optimizations:
  - Slow query logging (> 1s)
  - Connection pooling settings
- DB subnet group across 2 AZs
- Security group restricted to app subnet

**Outputs:**
- RDS endpoint (use in application connection strings)
- DB instance ID, resource ID

**Enable/Disable:** `enable_services.rds = true/false`

**Note:** Requires VPC module enabled

---

### 3. EC2 Module (`modules/ec2/`)
**Docker host for container deployments**

- Amazon Linux 2 AMI (latest)
- Configurable instance type (default: t3.medium)
- IAM role with CloudWatch logs permission
- CloudWatch agent for system metrics
- EBS optimized volume (30 GB default, configurable)
- User data script:
  - Docker CE installation
  - Docker Compose setup
  - CloudWatch agent configuration

**Outputs:**
- Instance ID, public/private IPs
- IAM role ARN

**Enable/Disable:** `enable_services.ec2 = true/false`

**Note:** Requires VPC module enabled

---

### 4. ALB Module (`modules/alb/`)
**Application Load Balancer with health checks**

- Application Load Balancer (Layer 7)
- Multi-AZ placement across 2 subnets
- Health checks:
  - Protocol: HTTP
  - Path: `/health`
  - Interval: 30s, timeout: 5s, healthy threshold: 2
- Target group for EC2/ECS instances
- HTTP listener (port 80)
- Tags for cost allocation

**Outputs:**
- ALB DNS name (use for accessing application)
- ALB ARN, target group ARN
- Target group name

**Enable/Disable:** `enable_services.alb = true/false`

**Note:** Requires VPC and EC2/ECS modules enabled

---

### 5. Monitoring Module (`modules/monitoring/`)
**CloudWatch logs, alarms, and dashboards**

- CloudWatch Log Group (7-day retention)
- CloudWatch Dashboard:
  - ALB request count, latency, errors
  - EC2 CPU, memory, disk usage
  - RDS CPU, connections, disk usage
  - ElastiCache hit/miss rates, evictions
- CloudWatch Alarms:
  - ALB HTTP 5XX errors (threshold: > 5% in 5 min)
  - EC2 CPU (threshold: > 80% for 10 min)
  - RDS CPU (threshold: > 80% for 10 min)
  - Database connections (threshold: > 80 connections)

**Outputs:**
- Log group name/ARN
- Dashboard URL
- Alarm names/ARNs

**Enable/Disable:** `enable_services.monitoring = true/false`

**Note:** Requires ALB, EC2/ECS, and RDS modules enabled

---

### 6. Security Module (`modules/security/`)
**Encryption, secrets management, and audit logging**

**KMS Encryption:**
- Customer-managed KMS key for RDS and Secrets Manager
- Automatic key rotation (annual)
- 30-day deletion window for key recovery
- Uses key alias for user-friendly reference

**Secrets Manager:**
- `{project_name}/{environment}/db-password` — Database admin password
- `{project_name}/{environment}/jwt-secret` — JWT signing key
- 30-day automatic rotation (manual for now)
- Encryption at rest using KMS key
- 7-day recovery window if accidentally deleted

**CloudTrail Audit Logging:**
- Logs all AWS API calls to dedicated S3 bucket
- CloudWatch Logs integration (7-day retention)
- Log file validation enabled (prevents tampering)
- Multi-region trail for global service events
- Data event logging for S3 and Lambda

**S3 Bucket for CloudTrail:**
- Versioning enabled
- Server-side encryption (AES-256)
- Public access blocked
- Bucket policy restricts access to CloudTrail only

**Outputs:**
- KMS key ID/ARN
- Secrets Manager secret names/ARNs
- CloudTrail ARN, S3 bucket name
- CloudWatch Log Group name

**Enable/Disable:** Always enabled (foundational security)

---

### 7. ECS Module (`modules/ecs/`)
**Container orchestration for microservices**

- ECS cluster with Container Insights enabled
- CloudWatch Logs for container logs (7-day retention)
- Service Discovery namespace for inter-service communication
- Ready for ECS Fargate service deployments

**Outputs:**
- ECS cluster ARN/name
- CloudWatch Log Group ARN
- Service Discovery namespace ARN/ID

**Enable/Disable:** `enable_services.ecs = true/false`

**Note:** Requires VPC module enabled

**Week 2+ Usage:**
Deploy ECS services/tasks in this cluster for microservices decomposition labs. Integrates with ALB for traffic routing.

---

### 8. ElastiCache Module (`modules/elasticache/`)
**Redis cluster for distributed caching**

- Redis 7.0 (configurable)
- Single-node deployment (t3.micro for lab)
- Encryption:
  - At-rest with KMS
  - In-transit via TLS
- Parameter group with optimizations:
  - `maxmemory-policy: allkeys-lru` — Evict least recently used keys
  - `notify-keyspace-events: Ex` — Key expiration notifications
- CloudWatch Logs:
  - Slow log (ops > 10ms)
  - Engine log (warnings, errors)
- CloudWatch Alarms:
  - CPU utilization > 75%
  - Memory utilization > 85%
  - Evictions > 1000/min

**Outputs:**
- Cluster ID, address, port, endpoint
- Engine/version, node type
- Subnet group name

**Enable/Disable:** `enable_services.elasticache = true/false`

**Note:** Requires VPC module enabled

---

## 🎛️ Configuration

### terraform.tfvars

```hcl
# AWS Configuration
aws_region   = "us-east-1"
environment  = "prod"
project_name = "task-app"

# Network Configuration
vpc_cidr               = "10.0.0.0/16"
app_subnet_cidr        = "10.0.1.0/24"
db_subnet_1_cidr       = "10.0.2.0/24"
db_subnet_2_cidr       = "10.0.3.0/24"
alb_subnet_1_cidr      = "10.0.4.0/24"
alb_subnet_2_cidr      = "10.0.5.0/24"

# Database Configuration
db_engine_version        = "14.9"
db_instance_class        = "db.t3.micro"
db_allocated_storage     = 20
db_name                  = "taskdb"
db_user                  = "dbadmin"
db_password              = "YourSecurePassword123!"  # CHANGE IN PRODUCTION
db_backup_retention_days = 7

# EC2 Configuration
instance_type    = "t3.medium"
key_pair_name    = "your-key-pair"  # Update with your key pair
ec2_volume_size  = 30
container_port   = 8000

# Application Configuration
docker_image_uri = "placeholder"  # Update after pushing to ECR
jwt_secret       = "your-secret-key-change-in-production"

# Feature Flags - Enable/Disable Services
enable_services = {
  vpc         = true   # VPC, subnets, security groups
  rds         = true   # PostgreSQL database
  ec2         = true   # Docker host
  alb         = true   # Application Load Balancer
  monitoring  = true   # CloudWatch dashboards/alarms
  ecs         = true   # ECS cluster (for Week 2+)
  elasticache = true   # Redis cache (for Week 4+)
}

# Multi-AZ Configuration
enable_multi_az = true
```

### Enable/Disable Services

Use boolean flags to selectively deploy resources:

```bash
# Deploy only VPC and RDS (minimal configuration)
terraform apply -var='enable_services={vpc=true,rds=true,ec2=false,alb=false,monitoring=false,ecs=false,elasticache=false}'

# Week 1: Full 3-tier architecture
terraform apply -var='enable_services={vpc=true,rds=true,ec2=true,alb=true,monitoring=true,ecs=false,elasticache=false}'

# Week 2: Replace EC2 with ECS microservices
terraform apply -var='enable_services={vpc=true,rds=true,ec2=false,alb=true,monitoring=true,ecs=true,elasticache=false}'

# Week 4: Add caching layer
terraform apply -var='enable_services={vpc=true,rds=true,ec2=false,alb=true,monitoring=true,ecs=true,elasticache=true}'
```

---

## 📊 Outputs

After deployment, Terraform outputs critical values:

```bash
terraform output

# Example output:
alb_dns_name = "task-app-alb-123456.us-east-1.elb.amazonaws.com"
rds_endpoint = "task-app-db.xxxxx.us-east-1.rds.amazonaws.com:5432"
elasticache_endpoint = "task-app-cache.xxxxx.ng.0001.use1.cache.amazonaws.com:6379"
ec2_instance_id = "i-0123456789abcdef"
ecs_cluster_name = "task-app-cluster"
kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT:key/xxxxx"
```

Access specific outputs:

```bash
terraform output alb_dns_name
terraform output rds_endpoint
terraform output elasticache_endpoint
```

---

## 🔐 Security Best Practices

### Secrets Management

**Never commit secrets to git:**

```bash
# ❌ WRONG
db_password = "MySecurePassword123!"

# ✅ CORRECT
db_password = var.db_password  # Passed via environment or -var flag
```

**Set secrets via environment variables:**

```bash
export TF_VAR_db_password="MySecurePassword123!"
export TF_VAR_jwt_secret="your-long-jwt-secret-key"
terraform plan
```

**Or use -var flag:**

```bash
terraform apply \
  -var="db_password=MySecurePassword123!" \
  -var="jwt_secret=your-long-jwt-secret-key"
```

**Retrieve secrets after deployment:**

```bash
# From Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id task-app/prod/db-password \
  --query SecretString --output text

# From EC2 Systems Manager Parameter Store (if using RDS Proxy)
aws ssm get-parameter \
  --name /rds/password/task-app-db \
  --with-decryption --query Parameter.Value --output text
```

### State Management

**Remote state (Terraform Cloud):**
```hcl
# terraform.tf - configured
cloud {
  organization = "evoketechnologies"
  workspaces {
    name = "aws-sa-prod"
  }
}
```

**Local state (development only):**
```bash
# terraform state is stored in terraform.tfstate
# Add to .gitignore to prevent accidental commits
echo "terraform.tfstate*" >> .gitignore
```

### Infrastructure Security

- **VPC Isolation:** All resources in private subnets (except ALB)
- **Least Privilege IAM:** EC2 instance can only write to CloudWatch Logs
- **Encryption:** KMS at-rest, TLS in-transit
- **Audit Trail:** CloudTrail logs all API calls
- **Secrets:** Stored in Secrets Manager with KMS encryption
- **Network ACLs:** Restrict traffic to necessary ports only

---

## 🧪 Testing & Validation

### Validate Configuration

```bash
terraform validate
```

### Review Planned Changes

```bash
terraform plan -out=tfplan
terraform show tfplan | head -100
```

### Check Specific Module

```bash
terraform plan -target=module.rds
terraform plan -target=module.security
```

### Destroy Specific Resources

```bash
# Destroy RDS only
terraform destroy -target=module.rds

# Destroy all infrastructure
terraform destroy
```

---

## 📈 Learning Path Integration

### Week 1: Foundational Architecture
Deploy all services (enable_services = all true)
- Understand VPC design, multi-AZ, security groups
- Deploy RDS with automated backups
- Launch EC2 instance with Docker
- Configure ALB health checks and routing
- Set up CloudWatch monitoring

### Week 2: Microservices Decomposition
Disable EC2, enable ECS
- Decompose monolith into ECS services
- Use service discovery for inter-service communication
- Deploy multiple ECS task definitions
- Test canary deployments

### Week 3: CI/CD Pipeline
- Integrate with GitLab CI / GitHub Actions
- Automated Terraform plan/apply in pipeline
- Docker image builds and ECR pushes

### Week 4: Caching Layer
Enable ElastiCache
- Integrate Redis into application
- Implement cache-aside pattern
- Monitor cache hit ratios

### Week 5: Security & Compliance
Verify Security module
- Review KMS encryption
- Test Secrets Manager rotation
- Audit CloudTrail logs for compliance

### Weeks 6-12: Advanced Topics
- Database optimization (RDS scaling, read replicas)
- Multi-region failover
- Disaster recovery RTO/RPO
- Cost optimization (Reserved Instances, Spot)

---

## 🔧 Troubleshooting

### "Module not installed" Error

```bash
terraform init -upgrade
```

### "Insufficient IAM permissions" Error

Ensure your AWS credentials have permissions for:
- VPC, Subnet, RouteTable, SecurityGroup
- RDS, EC2, ElastiCache, ALB
- KMS, Secrets Manager, CloudTrail
- CloudWatch, IAM

### "RDS endpoint not responding"

```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier task-app-db \
  --query 'DBInstances[0].DBInstanceStatus'

# Check security group
aws ec2 describe-security-groups \
  --group-ids sg-xxxxx
```

### "Application can't connect to database"

```bash
# From EC2 instance, test connectivity
ssh -i your-key.pem ec2-user@<ec2-public-ip>
psql -h <rds-endpoint> -U dbadmin -d taskdb

# Verify security group allows port 5432
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp --port 5432 \
  --source-group sg-app-sg
```

---

## 📝 File Structure

```
.
├── README.md                          # This file
├── main.tf                            # Module orchestration
├── variables.tf                       # Input variables
├── outputs.tf                         # Output values
├── terraform.tf                       # Provider & backend config
├── terraform.tfvars                   # Variable values (KEEP PRIVATE)
├── .gitignore                         # Ignore state, secrets
│
├── modules/
│   ├── vpc/                           # VPC, subnets, security groups
│   ├── rds/                           # PostgreSQL database
│   ├── ec2/                           # Docker host
│   ├── alb/                           # Application Load Balancer
│   ├── monitoring/                    # CloudWatch logs/alarms/dashboards
│   ├── security/                      # KMS, Secrets Manager, CloudTrail
│   ├── ecs/                           # ECS cluster
│   └── elasticache/                   # Redis cluster
│
└── docs/
    └── weeks/                         # 12-week learning curriculum
        ├── week-1/README.md           # Foundation labs
        └── ...
```

---

## 🚨 Production Checklist

Before deploying to production:

- [ ] Change all default values (db_password, jwt_secret, instance types)
- [ ] Set `enable_multi_az = true` for RDS
- [ ] Increase EC2 instance type to t3.large or m5.large
- [ ] Enable RDS automated minor version upgrades
- [ ] Configure RDS enhanced monitoring (Unified CloudWatch Agent)
- [ ] Set up SNS topics for alarm notifications
- [ ] Enable VPC Flow Logs for network troubleshooting
- [ ] Configure AWS Backup for automated recovery
- [ ] Review Security Hub findings
- [ ] Tag all resources for cost allocation
- [ ] Enable CloudTrail log file validation
- [ ] Rotate JWT secret quarterly
- [ ] Test RDS failover/recovery
- [ ] Document runbooks for common incidents

---

## 🤝 Contributing

Improvements to this learning infrastructure:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/add-efs-module`)
3. Commit changes (`git commit -am 'Add EFS module'`)
4. Push to branch (`git push origin feature/add-efs-module`)
5. Create Pull Request

---

## 📚 References

- [AWS Solutions Architect Associate Study Guide](https://docs.aws.amazon.com/whitepapers/latest/aws-well-architected-framework/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Week 1-12 Learning Roadmap](./ROADMAP.md)

---

**Last Updated:** April 3, 2026  
**Terraform Version:** >= 1.0  
**AWS Provider:** ~> 5.0
