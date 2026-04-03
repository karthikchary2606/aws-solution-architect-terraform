# Week 10: Advanced Security & Compliance

**Duration:** 7 days (14-16 hours total)  
**Exam Domains:** Security (primary), Operational Excellence (secondary)  
**Deliverable:** Hardened infrastructure with compliance automation

---

## Week Overview

Implement network security hardening (WAF, Network ACLs), enable advanced threat detection (GuardDuty, Macie), and automate compliance checking (Config, Security Hub).

By end of week:
- ✅ AWS WAF deployed on ALB
- ✅ VPC Flow Logs analyzed for anomalies
- ✅ GuardDuty enabled for threat detection
- ✅ AWS Config rules for compliance
- ✅ Security Hub dashboard created
- ✅ Penetration testing simulation completed

**Key Exam Concepts:**
1. WAF rules and patterns (OWASP Top 10)
2. Network ACLs vs Security Groups
3. VPC endpoint policies
4. GuardDuty and Macie findings
5. AWS Config rules and remediation

---

## Daily Breakdown

### **Day 1: WAF Configuration**
- Create WAF ACL
- Add rules for OWASP Top 10 (SQL injection, XSS, etc.)
- Attach to ALB
- Test blocking of malicious requests

### **Day 2: Network Segmentation**
- Review security group rules (remove permissive)
- Implement network ACLs (stateless filtering)
- Test egress restrictions
- Document network isolation strategy

### **Day 3: VPC Flow Logs Analysis**
- Enable VPC Flow Logs
- Stream to CloudWatch Logs
- Create Logs Insights queries for:
  - Rejected connections
  - Unusual ports
  - Failed auth attempts
- Set up alarms for suspicious patterns

### **Day 4: GuardDuty & Threat Detection**
- Enable GuardDuty (threat detection)
- Review finding types
- Create SNS notifications for findings
- Develop incident response procedures

### **Day 5: AWS Config & Compliance**
- Enable AWS Config
- Create Config rules for:
  - Encryption enabled (RDS, EBS)
  - No public S3 buckets
  - IAM policies reviewed
  - VPC Flow Logs enabled
- Implement auto-remediation where possible

### **Day 6: Security Hub & Aggregation**
- Enable Security Hub
- Aggregate findings from Config, GuardDuty, etc.
- Create custom dashboards
- Set up automated remediation

### **Day 7: Penetration Testing & Documentation**
- Conduct simulated attack scenarios
- Document security controls
- Create vulnerability disclosure policy
- Plan security incident response

---

## WAF Rule Examples

**SQL Injection Protection:**
```
Match SQL keywords in request body
Block if: SELECT, DROP, INSERT, UPDATE detected in input
```

**XSS Protection:**
```
Block if: <script>, javascript:, onerror= detected
```

**Rate Limiting:**
```
Block if: >1000 requests/minute from single IP
```

---

## Security Compliance Checklist

- [ ] All data encrypted at rest (KMS)
- [ ] All data encrypted in transit (TLS)
- [ ] IAM follows least privilege
- [ ] CloudTrail enabled for audit
- [ ] CloudWatch alarms for security events
- [ ] GuardDuty enabled
- [ ] Config rules enforced
- [ ] No hardcoded credentials
- [ ] VPC Flow Logs enabled
- [ ] WAF deployed on public ALB

---

**Next:** Week 11 - Operational Excellence & Observability
