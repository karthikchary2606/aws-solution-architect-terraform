# Week 8: Disaster Recovery & Backup Strategy

**Duration:** 7 days (14-16 hours total)  
**Exam Domains:** Reliability (primary)  
**Deliverable:** Comprehensive DR plan with tested backup/restore procedures

---

## Week Overview

Design and test disaster recovery strategy. Implement AWS Backup for automated backup management. Document RTO/RPO for all critical components. Conduct DR drills to validate recovery procedures.

By end of week:
- ✅ AWS Backup policies configured
- ✅ Automated backups for RDS, EBS, S3
- ✅ Point-in-time recovery tested
- ✅ RTO/RPO measured for all components
- ✅ Failover runbooks documented
- ✅ DR drill conducted (simulated region failure)

**Key Exam Concepts:**
1. RTO (Recovery Time Objective) calculations
2. RPO (Recovery Point Objective) calculations
3. AWS Backup vs native service backups
4. Backup frequency vs storage cost
5. Chaos engineering and DR testing

---

## Daily Breakdown

### **Day 1: Design RTO/RPO Requirements**
- Define RTO for each service (app: 15 min, DB: 5 min)
- Define RPO for each service (DB: 1 min, files: 1 hour)
- Calculate backup frequency needed for RPO
- Document in disaster recovery plan

### **Day 2: AWS Backup Configuration**
- Create backup vault (with encryption)
- Configure RDS backup policy (daily + hourly)
- Configure EBS backup policy (snapshots)
- Configure S3 lifecycle (Glacier for long-term)

### **Day 3: Point-in-Time Recovery Testing**
- Create test database
- Restore from backup to specific point-in-time
- Verify data consistency
- Document restore procedure time

### **Day 4: Automated Failover Testing**
- Test RDS primary failure
- Test ALB failure
- Test EC2 instance failure
- Measure RTO for each

### **Day 5: Application-Level Recovery**
- Document database connection string updates
- Test application reconnection logic
- Verify data consistency after failover
- Test graceful shutdown procedures

### **Day 6: Chaos Engineering**
- Terminate random resources
- Measure impact
- Verify automatic recovery
- Document findings

### **Day 7: DR Documentation & Drill**
- Create comprehensive runbook
- Document all RTO/RPO measurements
- Conduct full DR drill (simulate region failure)
- Document lessons learned

---

## Backup Strategy Matrix

| Component | Backup Method | Frequency | Retention | Cost |
|-----------|---|---|---|---|
| RDS | AWS Backup | Hourly | 30 days | $$ |
| EBS | Snapshots | Daily | 7 days | $ |
| S3 | Versioning | Continuous | 90 days | $$ |
| Secrets | Replicated | Real-time | Indefinite | $ |

---

## RTO/RPO by Component

**RDS Database:**
- RTO: 2-5 minutes (restore from backup)
- RPO: <1 minute (continuous transaction logs)

**EBS Volumes:**
- RTO: 5 minutes (restore snapshot)
- RPO: 24 hours (daily snapshots)

**S3 Objects:**
- RTO: Immediate (versioning)
- RPO: Real-time

---

**Next:** Week 9 - Cost Optimization & Reserved Capacity
