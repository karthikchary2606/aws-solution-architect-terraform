# Week 1 Assessment - VPC, EC2, RDS Foundation

**Passing Score:** 80% (12/15 questions)  
**Time Limit:** 1 hour  
**Format:** Mix of scenario-based and conceptual questions

---

## Part 1: Conceptual Questions (5 questions, 1 point each)

### Q1: VPC CIDR Calculation
Your VPC uses `10.0.0.0/16`. How many usable IP addresses does your VPC have?

**Options:**
A) 65,536  
B) 65,531  
C) 65,535  
D) 65,526  

**Answer:** B) 65,531

**Explanation:**
- /16 = 2^(32-16) = 2^16 = 65,536 total IPs
- AWS reserves 5 IPs per subnet for:
  - Network address (.0)
  - VPC router (.1)
  - DNS (.2)
  - Reserved for future use (.3)
  - Broadcast (.255)
- But in the VPC (not subnet), only the first and last are reserved
- So: 65,536 - 5 = 65,531
- **Exam Focus:** You need this for capacity planning. If you have 6 subnets and need 200 IPs each, will /16 fit?

---

### Q2: Multi-AZ Architecture
Your RDS instance is configured with `enable_multi_az = true`. Your primary instance fails. What happens?

**Options:**
A) Application goes down; manual intervention required  
B) Standby automatically promotes; 1-3 minutes of potential connection errors  
C) Read replica in same AZ automatically becomes primary  
D) Both primary and standby fail; backup must be restored  

**Answer:** B) Standby automatically promotes; 1-3 minutes of potential connection errors

**Explanation:**
- Multi-AZ RDS has a **synchronous standby** in different AZ
- On primary failure, standby automatically promotes (no manual action)
- RDS endpoint DNS points to new primary (old IP discarded)
- This is **automatic failover** ≠ read replica failover
- Application may see ~90 second interruption while promotion happens
- **Exam Focus:** This is the key difference between Multi-AZ (HA) and read replicas (read scaling)

---

### Q3: Security Groups
You have 3 security groups: ALB-SG, App-SG, Database-SG. Which ingress rules must you configure? (Select all that apply in real exam)

**Options:**
A) ALB-SG: 80 from 0.0.0.0/0  
B) App-SG: 8000 from ALB-SG  
C) Database-SG: 5432 from App-SG  
D) Database-SG: 5432 from 0.0.0.0/0  

**Answer:** A, B, C

**Explanation:**
- **ALB-SG:** Must accept HTTP (80) from internet (0.0.0.0/0)
  - This is your public-facing interface
  - Consider adding HTTPS (443) in production
  
- **App-SG:** Must accept 8000 from ALB-SG
  - **Never** accept from 0.0.0.0/0
  - Only ALB should route traffic to app
  - App is in private subnet, not directly accessible
  
- **Database-SG:** Must accept 5432 only from App-SG
  - **Never** open to 0.0.0.0/0 (Option D is wrong!)
  - Only app containers should access database
  - This is **least privilege**

- **Exam Focus:** Security group questions often test whether you understand "principle of least privilege". Don't give permissions to the internet when only internal services need it.

---

### Q4: ALB Health Checks
Your ALB health check is configured:
- Interval: 30 seconds
- Healthy threshold: 2
- Unhealthy threshold: 3

Your application crashes. How long until ALB stops sending traffic to that instance?

**Options:**
A) 30 seconds  
B) 60 seconds  
C) 90 seconds  
D) 120 seconds  

**Answer:** C) 90 seconds

**Explanation:**
- Health check runs every 30 seconds
- Unhealthy threshold = 3 consecutive failures
- Time = 30 seconds × 3 = **90 seconds**
- Timeline:
  - 0s: App crashes
  - 30s: First health check fails (1/3)
  - 60s: Second health check fails (2/3)
  - 90s: Third health check fails (3/3) → Target marked unhealthy
  - ALB stops sending new requests
- **Exam Focus:** RTO calculations. If your app crashes, 90 seconds of downtime minimum.

---

### Q5: Terraform State
You accidentally deleted your `terraform.tfstate` file but your infrastructure is still running in AWS. What happens when you run `terraform plan`?

**Options:**
A) Terraform knows about all your resources; no changes  
B) Terraform sees all resources missing from state; plans to recreate everything  
C) Terraform errors out; recovery is impossible  
D) Terraform asks AWS for current state automatically  

**Answer:** B) Terraform sees all resources missing from state; plans to recreate everything

**Explanation:**
- Terraform state is the **source of truth** for what it created
- State is separate from AWS reality
- Without state, Terraform has no record of what it created
- `terraform plan` would show:
  - All resources "to be created"
  - It would try to `terraform apply` and fail (resources already exist)
- **Recovery:**
  ```bash
  # Use terraform import to recover
  terraform import aws_vpc.main vpc-xxxxx
  terraform import aws_instance.main i-xxxxx
  # ... etc for all resources
  ```
- **Exam Focus:** Why teams use Terraform Cloud (remote state, backups, team access)

---

## Part 2: Scenario-Based Questions (10 questions, 1 point each)

### Q6: Architecture Review
Your company's application is getting 1000 requests/second. Your current architecture:
- Single EC2 t3.medium instance
- RDS Multi-AZ db.t3.micro
- Single ALB

What's your biggest bottleneck?

**Options:**
A) ALB can't handle 1000 req/s  
B) EC2 t3.medium CPU will max out  
C) RDS db.t3.micro will max out first  
D) Network throughput between services  

**Answer:** C) RDS db.t3.micro will max out first

**Explanation:**
- **ALB capacity:** Can handle 100,000+ req/s; not the bottleneck
- **EC2 t3.medium:** ~1-2 vCPU, handles ~500-1000 req/s with caching
- **RDS db.t3.micro:** ~1 vCPU, designed for small workloads (~20-50 connections)
  - Each request = DB connection
  - 1000 req/s = need connection pooling
  - db.t3.micro will struggle first
- **Solution:** Increase RDS instance class + implement connection pooling (PgBouncer)
- **Exam Focus:** Know capacity limits of each service tier

---

### Q7: Cost Optimization
Your monthly AWS bill is $5,000:
- RDS Multi-AZ db.t3.micro: $200/month
- EC2 t3.medium: $100/month (on-demand)
- ALB: $15/month
- Data transfer: $200/month
- Other: $4,485/month

Which single change would reduce your bill the most?

**Options:**
A) Switch RDS to single-AZ  
B) Switch EC2 to t3.small  
C) Switch EC2 to reserved instances  
D) Reduce data transfer (caching/CDN)  

**Answer:** D) Reduce data transfer (caching/CDN)

**Explanation:**
- **Data transfer** is $4,485 (89% of bill) → biggest savings potential
  - Add CloudFront CDN for static assets
  - Add Redis ElastiCache for app data caching
  - Expected savings: $2,000-3,000/month
  
- **Option A (single-AZ):** Saves $100 but loses redundancy. Bad trade-off.
  
- **Option B (smaller instance):** Saves ~$40. Minimal impact.
  
- **Option C (reserved instances):** Saves $30-40. Only applies to compute.
  
- **Exam Focus:** Always look at dominant cost (usually data transfer or compute at scale)

---

### Q8: RTO/RPO Calculation
You must meet these SLAs:
- RTO: 15 minutes
- RPO: 1 hour

Your current setup: Single EC2, RDS Multi-AZ with daily backups.

What's your RPO today?

**Options:**
A) 5 minutes  
B) 1 hour  
C) 24 hours  
D) Cannot calculate without knowing failure type  

**Answer:** C) 24 hours

**Explanation:**
- **RPO = Recovery Point Objective** = How much data can you lose?
- Your backups run **daily** (once per 24 hours)
- If disaster happens at 23:59, last backup was 23 hours ago
- You lose up to 24 hours of data
- **Current vs SLA:**
  - Current RPO: 24 hours
  - Required RPO: 1 hour
  - **Gap:** Need automated backups every hour (AWS Backup, or app-level logs)

- **RTO vs RPO:**
  - RTO is about **when** you recover (time to get back online)
  - RPO is about **how much data** you lose
  - These are independent!

---

### Q9: Multi-AZ Failover Impact
Your primary RDS instance in us-east-1a fails. The standby in us-east-1b promotes. What changes?

**Options:**
A) RDS endpoint changes to point to us-east-1b  
B) RDS endpoint stays the same (CNAME updated behind the scenes)  
C) You must manually update your application connection string  
D) All data written in the last 5 minutes is lost  

**Answer:** B) RDS endpoint stays the same (CNAME updated behind the scenes)

**Explanation:**
- RDS endpoint is a **DNS CNAME**, not an IP
- When primary fails, AWS updates the CNAME to point to standby
- Your application doesn't know or care; DNS resolves to new IP
- **Example:**
  ```
  task-app-db.xxxxx.us-east-1.rds.amazonaws.com
  
  Before failover: Points to IP 10.0.2.x (us-east-1a)
  After failover:  Points to IP 10.0.3.x (us-east-1b)
  ```
- Application keeps using same endpoint; failover is transparent
- **Exam Focus:** Never hardcode RDS IPs; always use DNS endpoints

---

### Q10: Monitoring & Alarms
You set an alarm: "Alert if EC2 CPU > 80% for 5 minutes"

Your CPU spikes to 85% for 3 minutes, then drops to 20%. What happens?

**Options:**
A) Alarm triggers (CPU was above 80%)  
B) Alarm doesn't trigger (didn't stay above 80% for 5 minutes)  
C) Alarm triggers after 5 minutes  
D) Alarm enters INSUFFICIENT_DATA state  

**Answer:** B) Alarm doesn't trigger (didn't stay above 80% for 5 minutes)

**Explanation:**
- Alarms require **sustained** threshold breach, not just a spike
- Your alarm: "CPU > 80% for 5 **consecutive** minutes"
- Your spike: 3 minutes above 80%, then drops below
- Alarm **never triggers** because condition not sustained
- **Timeline:**
  - 0m: CPU = 85%
  - 3m: CPU = 20% (condition broken, counter resets)
  - Alarm never reaches 5m threshold
- **Exam Focus:** Alarm behavior vs auto-scaling behavior:
  - Alarms: Fire if condition sustained
  - Auto-scaling: Can fire on shorter spikes (configurable)

---

### Q11: Terraform Drift Detection
You deploy infrastructure with Terraform. Then, using AWS Console, you manually change the ALB listener from HTTP to HTTPS.

What does `terraform plan` show?

**Options:**
A) No changes (Terraform doesn't track manual changes)  
B) Plan to delete ALB listener and recreate  
C) Plan to modify ALB listener (change from HTTP to HTTPS)  
D) Error: Conflicting configuration  

**Answer:** B) Plan to delete ALB listener and recreate

**Explanation:**
- Terraform state says: "Listener protocol = HTTP"
- AWS reality says: "Listener protocol = HTTPS"
- **Drift detected!**
- `terraform plan` shows correction:
  ```
  aws_lb_listener.http: Must be replaced
  - protocol = "HTTPS"
  + protocol = "HTTP"
  ```
- To fix drift:
  - Option 1: `terraform apply` (reverts to HTTP)
  - Option 2: `terraform import` to sync state with reality
  - **Best practice:** Never manually change Terraform-managed resources
- **Exam Focus:** Infrastructure as Code requires discipline. Manual changes = drift = disasters

---

### Q12: Cross-AZ Communication
Your ALB is in public subnets (us-east-1a, us-east-1b).
Your app instance is in private subnet (us-east-1a).

If your instance fails and you manually launch a replacement in us-east-1b, what happens?

**Options:**
A) ALB automatically routes to new instance; no changes needed  
B) ALB can't reach instance in us-east-1b; must add route in route table  
C) ALB routes to new instance after security group rule added  
D) Must update ALB to span us-east-1b  

**Answer:** A) ALB automatically routes to new instance; no changes needed

**Explanation:**
- ALB is already deployed in **both AZs**
  - ALB node in us-east-1a
  - ALB node in us-east-1b
- If you launch new instance in us-east-1b:
  - Register with ALB target group
  - ALB us-east-1b node will route to it
  - Security group allows traffic from ALB SG
  - **No additional routing needed**
  
- **Why this matters:**
  - ALB spreads across AZs for redundancy
  - Allows flexibility in instance placement
  - Single ALB serves instances in both AZs

- **Exam Focus:** ALB is designed for this; understand why you need cross-AZ subnets

---

### Q13: Database Backup Strategy
Your RDS has:
- Backup retention: 7 days
- Backup window: 03:00-04:00 UTC
- Multi-AZ: Yes

You discover data corruption at 10:00 UTC. Can you recover to yesterday (before corruption)?

**Options:**
A) Yes, restore from daily backup  
B) Yes, restore from continuous backups (transaction logs)  
C) No, 7-day retention means you can only go back 7 days  
D) No, data was corrupted for days; backups also corrupted  

**Answer:** B) Yes, restore from continuous backups (transaction logs)

**Explanation:**
- RDS maintains two types of backups:
  1. **Daily snapshots** (taken in backup window)
  2. **Transaction log backups** (continuous, every 5 minutes)
  
- With transaction logs, you can restore to **any point in time** within 7 days
- Your recovery:
  ```
  Restore from 09:55 UTC (5 minutes before corruption detected)
  ```
- **Exam Focus:** "Point-in-time recovery" is a key RDS feature
- You don't have to restore to the last snapshot; you can go to any specific minute

---

### Q14: VPC Endpoint Use Case
Your application needs to read/write to S3. Currently, all S3 requests go through NAT Gateway.

You implement a VPC endpoint for S3. What changes?

**Options:**
A) S3 requests now free (no data transfer charges)  
B) S3 requests faster (fewer hops)  
C) Both A and B  
D) Neither; no change in cost or performance  

**Answer:** C) Both A and B

**Explanation:**
- **Current (without VPC endpoint):**
  - Instance → (private subnet) → NAT Gateway → Internet → S3
  - Charges: $0.45/GB for NAT data transfer
  - Latency: ~100ms (multiple hops)

- **With VPC endpoint:**
  - Instance → (private subnet) → VPC endpoint → S3
  - Charges: **Free** (AWS-internal traffic)
  - Latency: ~10ms (direct connection)

- **Cost savings example:**
  - 1TB/day S3 traffic
  - Without endpoint: $450/month data transfer
  - With endpoint: $0/month
  - Savings: $450/month

- **Exam Focus:** VPC endpoints are cost & performance optimization for AWS-internal services

---

### Q15: Disaster Recovery Plan
Your boss asks: "What's our recovery plan if us-east-1 entire region goes down?"

Your current architecture: All in us-east-1

What should you say?

**Options:**
A) "Regional failure is unlikely; we don't need multi-region"  
B) "We have RDS Multi-AZ, so we're protected"  
C) "We need infrastructure in us-west-2 as backup; this will take weeks to implement"  
D) "We should implement cross-region RDS replica and secondary infrastructure"  

**Answer:** D) "We should implement cross-region RDS replica and secondary infrastructure"

**Explanation:**
- **Multi-AZ** protects against **AZ failure**, not **region failure**
- Region outages do happen (rare but real):
  - 2011: us-east-1 outage (power event)
  - 2012: us-east-1 outage (DNS issues)
  - 2021: us-east-1 outage (capacity event)
  
- **Required for region failover:**
  1. RDS replica in different region (read-only or promoted on failover)
  2. Secondary infrastructure (EC2, ALB) in us-west-2
  3. Route 53 health checks + failover routing
  4. Automated failover or runbook

- **Reality check:**
  - Option A (ignore risk): Irresponsible
  - Option B (multi-AZ only): Insufficient
  - Option C (weeks to implement): Too slow; should be ongoing
  - Option D (cross-region): Correct

- **Exam Focus:** Multi-region is Week 7 of your roadmap for exactly this reason

---

## Scoring Guide

**15-13 points (100-87%):** Excellent. Ready for Week 2.  
**12-10 points (80-67%):** Good. Review weak areas before Week 2.  
**9-7 points (60-47%):** Needs review. Re-read Week 1 materials and retry.  
**<7 points (<47%):** Schedule extra time. Consider pausing and re-doing Week 1 labs.

---

## Review by Weakness

**If you missed questions on:**
- **VPC/Subnets (Q1, Q3)** → Re-read: VPC design section in ROADMAP.md
- **Multi-AZ/RDS (Q2, Q8, Q9, Q13)** → Review: RDS backup & recovery documentation
- **Monitoring/Alarms (Q4, Q10)** → Re-do: Day 5 (CloudWatch) lab
- **Architecture/Capacity (Q6, Q7)** → Think about: How many instances needed for 1000 req/s?
- **IaC/Terraform (Q5, Q11)** → Practice: Manually change a resource in AWS Console, then `terraform plan`
- **Failover/DR (Q12, Q14, Q15)** → Preview: Week 8 (Disaster Recovery)

---

## Next Steps

- [ ] Score your assessment
- [ ] Review any questions you missed
- [ ] Note weak areas for later weeks
- [ ] Ready for **Week 2: Microservices Decomposition**

**Passing score:** You're ready to proceed!  
**Below 80%:** Review the weak area and re-take assessment before Week 2.

Good luck! 💪
