# Week 9: Cost Optimization & Reserved Capacity

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Cost Optimization (primary), Sustainability (secondary)  
**Deliverable:** Optimized infrastructure with cost reduction plan

---

## Week Overview

Analyze AWS spending, right-size instances, purchase reserved instances and savings plans. Implement cost allocation tags for chargeback. Target 20-30% cost reduction through optimization.

By end of week:
- ✅ Cost allocation tags applied
- ✅ AWS Cost Explorer analysis completed
- ✅ Compute Optimizer recommendations implemented
- ✅ Reserved instances purchased for baseline load
- ✅ Spot instances enabled for non-critical workloads
- ✅ Cost optimization roadmap documented

**Key Exam Concepts:**
1. Reserved Instance (RI) vs Savings Plans vs On-Demand
2. Spot instances and interruption handling
3. Right-sizing based on utilization
4. Cost anomaly detection
5. Sustainability (energy-efficient instance types)

---

## Daily Breakdown

### **Day 1: Cost Analysis**
- Open AWS Cost Explorer
- Analyze costs by service (RDS, EC2, ALB, etc.)
- Identify top cost drivers
- Compare against baseline

### **Day 2: Cost Allocation Tags**
- Add tags to all resources:
  - Environment: prod/dev
  - Service: user-service/task-service/db
  - Owner: team name
- Create cost allocation reports

### **Day 3: Compute Optimizer**
- Run Compute Optimizer recommendations
- Identify over-sized instances
- Test smaller instance types
- Document performance impact

### **Day 4: Reserved Instances**
- Calculate baseline load (minimum always-on instances)
- Purchase 1-year RI for baseline
- Compare cost: RI vs On-Demand
- Calculate annual savings

### **Day 5: Spot Instances**
- Identify non-critical services (dev/test)
- Enable Spot instances (30-90% discount)
- Configure fallback to On-Demand
- Test interruption handling

### **Day 6: Storage Optimization**
- Analyze S3 usage by bucket
- Enable S3 Intelligent-Tiering
- Archive old backups to Glacier
- Review RDS storage allocation

### **Day 7: Cost Report & Optimization Plan**
- Document baseline monthly cost: $X
- Document optimized monthly cost: $X-30%
- Calculate annual savings
- Create ongoing cost management process

---

## Cost Optimization Checklist

- [ ] Reserved instances purchased for 80%+ of stable load
- [ ] Spot instances enabled for non-critical workloads
- [ ] All resources properly tagged
- [ ] Unused resources identified and removed
- [ ] Storage optimized (S3 lifecycle, RDS sizing)
- [ ] NAT Gateway optimized or VPC endpoints used
- [ ] Data transfer costs analyzed and reduced

---

## Typical Savings

**Baseline (all On-Demand):** $5,000/month
- EC2: $2,000 (t3.medium x10)
- RDS: $1,500 (multi-AZ)
- Other: $1,500

**Optimized (~30% savings):** $3,500/month
- EC2 RIs: $1,200 (30% discount)
- Spot for non-prod: $300 (70% discount)
- RDS optimization: $1,000 (right-sized)
- Other: $1,000

**Annual savings:** $18,000+

---

**Next:** Week 10 - Advanced Security & Compliance
