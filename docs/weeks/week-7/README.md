# Week 7: Multi-Region Architecture (Active-Active)

**Duration:** 7 days (14-16 hours total)  
**Exam Domains:** Reliability (primary), Performance (secondary)  
**Deliverable:** Deployed active-active application across 2 AWS regions

---

## Week Overview

Design and deploy your application in multiple regions (us-east-1, us-west-2). Implement RDS Global Database, Route 53 geolocation routing, and cross-region failover. Test failover under load.

By end of week:
- ✅ Infrastructure deployed to us-west-2
- ✅ RDS Global Database (primary: us-east-1, replica: us-west-2)
- ✅ Route 53 routing (geolocation or latency-based)
- ✅ Cross-region ALB failover
- ✅ Replication monitoring and alerting
- ✅ Failover tested under load

**Key Exam Concepts:**
1. Route 53 routing policies (geolocation, latency, weighted, failover)
2. RDS Global Database vs cross-region read replicas
3. Cross-region failover RTO/RPO
4. Data replication lag and consistency
5. Cost of multi-region (double infrastructure)

---

## Daily Breakdown

### **Day 1: Route 53 & DNS Strategy**
- Create Route 53 hosted zone
- Plan routing policy (geolocation vs latency)
- Design failover strategy
- Document DNS failover behavior

### **Day 2: Deploy Infrastructure to us-west-2**
- Duplicate Terraform modules for second region
- Deploy VPC, subnets, RDS in us-west-2
- Deploy ECS cluster in us-west-2
- Create ALB in us-west-2

### **Day 3: RDS Global Database Setup**
- Enable RDS Global Database (us-east-1 primary)
- Configure us-west-2 as read-only replica region
- Monitor replication lag
- Set lag threshold alarms

### **Day 4: Route 53 Failover Configuration**
- Create health checks for both ALBs
- Configure weighted routing (50/50 or geolocation)
- Test DNS failover time
- Verify users routed to closest region

### **Day 5: Cross-Region Failover Testing**
- Simulate us-east-1 ALB failure
- Verify Route 53 detects failure (health check)
- Verify traffic shifts to us-west-2
- Measure failover time (target: <60 seconds)

### **Day 6: Replication Monitoring & Optimization**
- Monitor RDS replication lag (<1 second target)
- Set up CloudWatch metrics for lag
- Test write-heavy scenarios
- Document replication behavior

### **Day 7: Multi-Region Runbook & Testing**
- Document failover procedures
- Create disaster recovery playbook
- Test full region failure scenario
- Document cost analysis (2x infrastructure)

---

## Route 53 Routing Policies

**Geolocation:**
- Users in USA → us-east-1
- Users in Europe → eu-west-1
- Default → closest region

**Latency-based:**
- Route to region with lowest latency
- Automatic optimization based on network

**Weighted:**
- A% traffic to us-east-1
- B% traffic to us-west-2
- Good for gradual rollouts

---

## RTO/RPO Multi-Region

**Planned failover:**
- RTO: 5 minutes (DNS propagation)
- RPO: <1 second (RDS replication lag)

**Unplanned failover:**
- RTO: 2-5 minutes (health check + DNS)
- RPO: <5 seconds (replication lag spike)

---

**Next:** Week 8 - Disaster Recovery & Backup Strategy
