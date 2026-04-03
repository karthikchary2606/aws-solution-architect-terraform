# AWS Solutions Architect Professional Exam - 12-Week Intensive Roadmap

**Target Score:** 900+/1000  
**Weekly Commitment:** 10-15 hours  
**Learning Pattern:** Microservices-to-Enterprise (Progressive Architectural Complexity)  
**Start Date:** Week 1  

---

## 📋 Executive Summary

This roadmap transforms you from baseline 3-tier application to enterprise-grade AWS architecture through hands-on labs. Each week focuses on specific exam domains while building real infrastructure using Terraform and deploying to AWS.

**Your Advantage:** You have 8 years AWS/DevOps experience. This roadmap skips basics and jumps straight to architect-level patterns, trade-offs, and edge cases tested in the exam.

---

## 🎯 Exam Domain Coverage (Mapped to Weeks)

| Domain | Weight | Weeks | Key Topics |
|--------|--------|-------|-----------|
| **Reliability** | 18% | 1, 2, 8, 10 | Multi-AZ, failover, RTO/RPO, disaster recovery, SLAs |
| **Performance** | 18% | 3, 4, 6, 9 | Caching, CDN, database optimization, scaling patterns |
| **Cost Optimization** | 16% | 7, 9, 11 | Reserved instances, spot instances, right-sizing, storage tiers |
| **Security** | 20% | 5, 10, 12 | Encryption, IAM, secrets management, network isolation, compliance |
| **Operational Excellence** | 18% | 1, 6, 8, 11 | Monitoring, logging, automation, incident response, runbooks |
| **Sustainability** | 10% | 9, 12 | Energy efficiency, resource optimization, right-sizing |

---

## 📅 12-Week Timeline

### **Phase 1: Foundation (Weeks 1-3)**
Build baseline infrastructure, decompose monolith into microservices, establish CI/CD.

### **Phase 2: Scale & Optimize (Weeks 4-6)**
Add caching layers, implement database optimization, scale across regions.

### **Phase 3: Resilience (Weeks 7-9)**
Multi-region failover, disaster recovery, cost optimization, performance tuning.

### **Phase 4: Enterprise (Weeks 10-12)**
Security hardening, governance frameworks, compliance automation, final exam prep.

---

## Week-by-Week Breakdown

### **Week 1: VPC, EC2, RDS — 3-Tier Foundation**
- **Theme:** Design & deploy baseline 3-tier application on AWS
- **AWS Domains:** Reliability, Operational Excellence (foundations)
- **Exam Focus:** VPC design, security groups, RDS multi-AZ, monitoring
- **Deliverables:**
  - ✅ Terraform modules: VPC, EC2, RDS, ALB, monitoring (COMPLETED)
  - ✅ 3-tier application deployed to EC2
  - ✅ RDS PostgreSQL multi-AZ configured
  - ✅ ALB with health checks
  - ✅ CloudWatch alarms and dashboard
  - Assessment: Design quiz (VPC/RDS tradeoffs)

### **Week 2: Microservices Decomposition & ECS**
- **Theme:** Split monolith into services, containerize, deploy to ECS
- **AWS Domains:** Reliability, Operational Excellence
- **Exam Focus:** ECS task definitions, service discovery, IAM roles, container networking
- **Deliverables:**
  - Decompose task-app into: User Service, Task Service, Auth Service
  - Create ECS task definitions for each microservice
  - Deploy to ECS Fargate (or EC2 cluster)
  - Service discovery with CloudMap
  - Assessment: Architecture lab (design failover for one service)

### **Week 3: CI/CD Pipeline & GitOps**
- **Theme:** Automate build, test, and deployment pipeline
- **AWS Domains:** Operational Excellence
- **Exam Focus:** CodePipeline, CodeBuild, CodeDeploy, GitOps with ArgoCD
- **Deliverables:**
  - GitHub Actions or GitLab CI pipeline for task-app
  - Build Docker images → push to ECR
  - Automated tests (unit + integration)
  - Deployment automation via Terraform
  - Assessment: CI/CD troubleshooting scenario

### **Week 4: Caching Layer (ElastiCache + CloudFront)**
- **Theme:** Add caching for performance and cost optimization
- **AWS Domains:** Performance, Cost Optimization
- **Exam Focus:** Redis vs Memcached, cache invalidation, CloudFront CDN, cache-busting strategies
- **Deliverables:**
  - Deploy Redis cluster (ElastiCache) for session caching
  - Implement application-level caching (app cache layer)
  - CloudFront distribution for static assets
  - Cache hit ratio monitoring
  - Assessment: Performance tuning lab (optimize slow queries)

### **Week 5: Encryption, Secrets, IAM — Security Foundation**
- **Theme:** Implement encryption at rest/transit, manage secrets, least-privilege IAM
- **AWS Domains:** Security (primary), Operational Excellence
- **Exam Focus:** KMS, Secrets Manager, IAM policies, encryption strategies, certificate management
- **Deliverables:**
  - Enable RDS encryption with KMS
  - Migrate secrets to AWS Secrets Manager (DB passwords, JWT keys)
  - Audit IAM roles (EC2, ECS, Lambda) for least privilege
  - Enable VPC Flow Logs and CloudTrail
  - Implement TLS/SSL for all endpoints
  - Assessment: Security audit (find and fix IAM over-provisioning)

### **Week 6: Database Optimization & Scaling**
- **Theme:** Optimize database performance, implement read replicas, scaling strategies
- **AWS Domains:** Performance, Reliability
- **Exam Focus:** RDS read replicas, Aurora Global Database, connection pooling, query optimization, DMS
- **Deliverables:**
  - Create RDS read replica in different AZ
  - Implement connection pooling (PgBouncer or app-level)
  - Analyze slow query logs and optimize
  - Set up database backup automation
  - Plan Aurora migration (but don't implement yet)
  - Assessment: Database scaling scenario (handle 10x traffic spike)

### **Week 7: Multi-Region Architecture (Active-Active)**
- **Theme:** Design and deploy active-active multi-region application
- **AWS Domains:** Reliability, Performance, Cost Optimization
- **Exam Focus:** Route 53 routing policies, RDS Global Database, cross-region failover, replication lag
- **Deliverables:**
  - Deploy identical infrastructure to us-west-2
  - Configure RDS Global Database (primary: us-east-1, replica: us-west-2)
  - Route 53 geolocation or latency-based routing
  - Cross-region ALB failover testing
  - Data replication monitoring (CloudWatch, log analysis)
  - Assessment: Disaster recovery runbook (region failure)

### **Week 8: Disaster Recovery & Backup Strategy**
- **Theme:** Design RTO/RPO, backup automation, disaster recovery testing
- **AWS Domains:** Reliability (primary), Operational Excellence
- **Exam Focus:** AWS Backup, backup strategies (full/incremental), RTO/RPO calculations, chaos engineering
- **Deliverables:**
  - Design and document RTO/RPO targets for each component
  - Implement AWS Backup for RDS, EBS, S3
  - Automated backup testing (restore and validate)
  - Failover runbooks (regional failover, service-level failover)
  - Chaos engineering: test failover under load
  - Assessment: DR drill (simulate region failure, measure RTO)

### **Week 9: Cost Optimization & Reserved Capacity**
- **Theme:** Optimize AWS spend, right-size instances, implement reserved instances
- **AWS Domains:** Cost Optimization (primary), Sustainability
- **Exam Focus:** Cost allocation tags, RI/SP, compute optimization, storage tiers, AWS Compute Optimizer
- **Deliverables:**
  - Implement cost allocation tags across all resources
  - Run AWS Cost Explorer analysis (identify spend drivers)
  - Right-size instances using Compute Optimizer
  - Purchase reserved instances for baseline load
  - Implement spot instances for non-critical workloads
  - Document cost optimization roadmap
  - Assessment: Cost analysis lab (reduce spend by 20%)

### **Week 10: Advanced Security & Compliance**
- **Theme:** Network security hardening, compliance automation, vulnerability management
- **AWS Domains:** Security (primary), Operational Excellence
- **Exam Focus:** WAF, Network ACLs, VPC endpoints, guard rails, Config rules, Macie
- **Deliverables:**
  - Deploy AWS WAF on ALB (block common attacks)
  - Implement VPC Flow Logs analysis with CloudWatch Logs Insights
  - AWS Config rules for compliance automation
  - VPC endpoints for private S3/DynamoDB access
  - Enable GuardDuty for threat detection
  - Network segmentation (East-West security)
  - Assessment: Penetration testing scenario (find and fix vulns)

### **Week 11: Operational Excellence & Observability**
- **Theme:** Observability at scale, incident response, automation runbooks
- **AWS Domains:** Operational Excellence (primary), Reliability
- **Exam Focus:** X-Ray distributed tracing, structured logging, anomaly detection, OpsCenter, Incident Manager
- **Deliverables:**
  - X-Ray tracing for all microservices
  - Centralized logging (CloudWatch Logs → ELK or similar)
  - Custom metrics and CloudWatch dashboards for SLOs
  - Anomaly detection for KPIs
  - Automated incident response (Lambda automation)
  - Runbook library for common operational tasks
  - Assessment: Incident response simulation (diagnose and fix issue)

### **Week 12: Enterprise Governance & Exam Prep**
- **Theme:** Multi-account governance, policy enforcement, final exam preparation
- **AWS Domains:** All (final synthesis), Security
- **Exam Focus:** AWS Organizations, SCPs, Control Tower, AWS SSO, landing zones, architecture patterns from all domains
- **Deliverables:**
  - Design multi-account strategy (dev, staging, prod, shared services)
  - Document architecture patterns learned (Anti-patterns, tradeoffs)
  - Complete 3-4 full mock exams (score 850+)
  - Create personal cheat sheet (key formulas, trade-offs, service comparisons)
  - Review all 12 weeks' labs and assessments
  - Assessment: Comprehensive 3-hour mock exam

---

## 🛠️ Tools & Prerequisites

**Already Set Up:**
- ✅ AWS Account with appropriate permissions
- ✅ Terraform + Terraform Cloud (evoketechnologies org)
- ✅ GitHub/GitLab for source control
- ✅ Docker and Docker Compose
- ✅ AWS CLI configured

**Labs Assume:**
- Task app deployed on EC2 (Week 1)
- Terraform state managed in Terraform Cloud
- Infrastructure in `aws-solution-architect-terraform/`
- Application code in `aws-solution-architect-labs/`

---

## 📊 Success Criteria

**By End of Week 1:**
- ✅ Infrastructure deployed and healthy
- ✅ Application accessible via ALB
- ✅ CloudWatch monitoring working
- ✅ Diagnostic exam completed (identify weak domains)

**By End of Week 6:**
- ✅ Microservices deployed to ECS
- ✅ Caching layer functional
- ✅ Security baseline implemented (encryption, secrets, IAM)
- ✅ Multi-AZ failover tested

**By End of Week 12:**
- ✅ Multi-region active-active deployment
- ✅ Disaster recovery tested (RTO measured)
- ✅ Cost optimized (target: 30% reduction from baseline)
- ✅ Enterprise governance framework documented
- ✅ Mock exam score: 850+/1000

---

## 🎓 Exam Strategy

**Domains to prioritize (by exam weight):**
1. **Security** (20%) — Weeks 5, 10, 12
2. **Reliability** (18%) — Weeks 1, 2, 8, 10
3. **Performance** (18%) — Weeks 3, 4, 6, 9
4. **Operational Excellence** (18%) — Weeks 1, 3, 8, 11
5. **Cost Optimization** (16%) — Weeks 7, 9, 11
6. **Sustainability** (10%) — Weeks 9, 12

**Your Strengths** (leverage in exam):
- Deep DevOps/Terraform background → architecture as code
- 8 years AWS experience → recognize service patterns immediately
- Container expertise → ECS, ECR, task definitions intuitive

**Potential Weak Spots** (study hard):
- Multi-region failover edge cases
- Cost optimization trade-offs
- Compliance and governance patterns
- Disaster recovery RTO/RPO calculations

---

## 📝 Daily Time Allocation

**Typical Week: 10-15 hours**
- **Monday-Wednesday:** Lab implementation (4-5 hours/day)
- **Thursday:** Lab testing & troubleshooting (2-3 hours)
- **Friday:** Assessment quiz + review (2 hours)
- **Weekend:** Study theory, mock exams (2-4 hours optional)

**Reading Materials:**
- AWS Well-Architected Framework whitepapers (read by Week 6)
- Exam guide and sample questions (read Week 12)
- AWS re:Invent videos (bonus, 30 min/week)

---

## 🚀 Getting Started

**Week 1 Kickoff:**
1. Review infrastructure already deployed (Terraform state)
2. Access application via ALB DNS name
3. Day 1-7: Follow `docs/weeks/week-1/README.md` for daily tasks
4. Day 7: Complete Week 1 assessment quiz

**Each Subsequent Week:**
1. Read `docs/weeks/week-{N}/README.md` overview
2. Execute daily labs (days 1-7)
3. Complete week assessment by Friday
4. Update progress checklist

---

## 📚 Reference Architecture Diagram

```
Week 1-3: Foundation
┌──────────────────────────────────┐
│   Internet (Route 53)             │
│           │                       │
│       (ALB)                       │
│      /     \                      │
│   (EC2)  (EC2)  ← Multi-AZ       │
│     │       │                     │
│   (RDS Primary) ← Multi-AZ RDS   │
└──────────────────────────────────┘

Week 4-6: Microservices + Caching
┌──────────────────────────────────────────┐
│   Route 53 / CloudFront (CDN)            │
│           │                              │
│       (ALB)                              │
│    /   |   |   \                         │
│  (User)(Task)(Auth)(Admin)  ← ECS       │
│    \   |   |   /                         │
│    (ElastiCache Redis)                   │
│    \   |   |   /                         │
│    (RDS w/ Read Replicas)                │
└──────────────────────────────────────────┘

Week 7-9: Multi-Region
┌──────────────────────────────────────────┐
│   Route 53 (Geo-routing)                 │
│      /              \                    │
│   us-east-1      us-west-2               │
│  (Primary)    (Secondary)                │
│  (All Services)  (All Services)          │
│  (RDS Primary)   (RDS Replica)           │
│       ↔ RDS Global Database ↔           │
└──────────────────────────────────────────┘

Week 10-12: Enterprise
┌────────────────────────────────────────────────┐
│   AWS Organizations (Multi-Account)            │
│   ├─ Prod Account                              │
│   │  └─ Multi-region (us-east-1, us-west-2)   │
│   ├─ Dev Account                               │
│   └─ Shared Services Account                   │
│   (All with centralized logging, monitoring)   │
└────────────────────────────────────────────────┘
```

---

## 📞 Support & Troubleshooting

**If stuck:**
1. Check week-specific README for that section
2. Review CloudWatch Logs and application logs
3. Re-run `terraform plan` to detect configuration drift
4. Check AWS Console for resource state
5. Review assessment answers (they contain explanations)

**Common Issues & Fixes** → See `docs/TROUBLESHOOTING.md`

---

## 🎯 Final Exam Preparation

**Week 12 Activities:**
1. Complete 3 full mock exams (Whizlabs, Jon Bonso, TutorialsDojo)
2. Score tracking: Target 850+ before exam date
3. Review weak domain areas (re-do relevant week's labs)
4. Build personal formula/cheat sheet for tricky concepts
5. Schedule exam date (give yourself 1 week buffer after Week 12 completion)

**Exam Day:**
- 3 hours, 75 questions (scenario-based)
- Passing score: 720/1000
- Your target: 900+/1000

---

## 📖 Document Map

```
aws-solution-architect-terraform/
├── ROADMAP.md (this file)
├── docs/
│   ├── weeks/
│   │   ├── week-1/
│   │   │   ├── README.md (overview)
│   │   │   ├── day-1.md (daily task)
│   │   │   ├── day-2.md
│   │   │   ├── ...day-7.md
│   │   │   ├── assessment.md (quiz + answers)
│   │   │   └── solution/ (reference code)
│   │   ├── week-2/
│   │   └── ...week-12/
│   ├── TROUBLESHOOTING.md
│   └── CHEATSHEET.md (formulas, trade-offs)
├── terraform/ (infrastructure code)
└── labs/ (lab reference solutions)
```

---

**Next Step:** Go to `docs/weeks/week-1/README.md` and start Day 1.

Good luck. You've got this. 💪
