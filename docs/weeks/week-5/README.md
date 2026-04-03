# Week 5: Encryption, Secrets & IAM - Security Foundation

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Security (primary)  
**Deliverable:** End-to-end encryption and secrets management

---

## Week Overview

Implement encryption at rest (KMS) and in transit (TLS). Migrate secrets to AWS Secrets Manager. Audit and tighten IAM permissions (least privilege). Enable CloudTrail and VPC Flow Logs for compliance.

By end of week:
- ✅ RDS encryption with KMS enabled
- ✅ All secrets in Secrets Manager (DB password, JWT keys)
- ✅ TLS/SSL on all endpoints (ALB, API)
- ✅ IAM roles with least privilege
- ✅ CloudTrail logging enabled
- ✅ VPC Flow Logs enabled

**Key Exam Concepts:**
1. KMS (Key Management Service) - encryption key lifecycle
2. Secrets Manager vs Systems Manager Parameter Store
3. IAM policy conditions and resource-based policies
4. CloudTrail vs VPC Flow Logs vs CloudWatch Logs
5. Encryption at rest vs in transit vs in use

---

## Daily Breakdown

### **Day 1: KMS & RDS Encryption**
- Create KMS key for database encryption
- Enable RDS encryption at rest
- Understand key rotation
- Test backup encryption

### **Day 2: Secrets Manager Migration**
- Create Secrets Manager secrets for:
  - RDS database password
  - JWT signing key
  - OAuth credentials (future)
- Rotate secrets strategy
- Update application to read from Secrets Manager

### **Day 3: TLS/SSL Configuration**
- Request ACM certificate for domain
- Configure ALB for HTTPS (443)
- Force HTTP→HTTPS redirect
- Test certificate validity

### **Day 4: IAM Least Privilege Audit**
- Review EC2 instance IAM role
- Review ECS task execution/task roles
- Audit Lambda execution roles (if added)
- Document principle of least privilege

### **Day 5: CloudTrail & VPC Flow Logs**
- Enable CloudTrail (all API calls)
- Enable VPC Flow Logs
- Send logs to CloudWatch
- Create CloudWatch Logs Insights queries

### **Day 6: Security Testing**
- Verify RDS encryption with KMS
- Verify no secrets in code (git-secrets)
- Test that services can't access Secrets Manager without IAM role
- Audit CloudTrail for unauthorized API calls

### **Day 7: Compliance & Documentation**
- Document encryption keys (KMS key IDs)
- Document secrets rotation policy
- Create security incident runbook
- Document IAM permissions (who can do what)

---

## Key Configurations

**RDS Encryption:**
```hcl
storage_encrypted = true
kms_key_id        = aws_kms_key.rds.arn
```

**Secrets Manager:**
```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "rds/db-password"
  
  rotation_rules {
    automatically_after_days = 30
  }
}
```

**IAM Least Privilege:**
```json
{
  "Effect": "Allow",
  "Action": [
    "rds-db:connect"  // Not full RDS API
  ],
  "Resource": [
    "arn:aws:rds:region:account:db:task-app-db"
  ]
}
```

---

## Assessment Quiz

15 questions on:
- KMS encryption scenarios
- Secrets Manager vs Parameter Store trade-offs
- IAM policy evaluation logic
- Certificate management
- Compliance and auditing

---

**Next:** Week 6 - Database Optimization & Scaling
