# Week 11: Operational Excellence & Observability

**Duration:** 7 days (14-16 hours total)  
**Exam Domains:** Operational Excellence (primary), Reliability (secondary)  
**Deliverable:** Complete observability and incident response framework

---

## Week Overview

Implement distributed tracing (X-Ray), centralized logging, custom metrics, and anomaly detection. Create runbooks and OpsCenter for automated incident response. Monitor SLOs (Service Level Objectives).

By end of week:
- ✅ X-Ray distributed tracing enabled
- ✅ Centralized logging (CloudWatch Logs Insights)
- ✅ Custom metrics and SLO dashboards
- ✅ Anomaly detection configured
- ✅ OpsCenter runbooks created
- ✅ Incident response automated

**Key Exam Concepts:**
1. X-Ray service map and insights
2. Structured logging and correlation IDs
3. SLO vs SLA vs SLI metrics
4. Anomaly detection algorithms
5. Incident management automation

---

## Daily Breakdown

### **Day 1: X-Ray Distributed Tracing**
- Enable X-Ray on ECS services
- Add X-Ray instrumentation to application
- Create service map (see service dependencies)
- Analyze latency bottlenecks

### **Day 2: Centralized Logging**
- Stream ECS logs to CloudWatch Logs
- Create log groups for each service
- Implement structured logging (JSON)
- Add correlation IDs to traces

### **Day 3: CloudWatch Logs Insights Queries**
- Query error rates by service
- Query latency percentiles (p50, p95, p99)
- Query database connection issues
- Create saved queries for common investigations

### **Day 4: Custom Metrics & Dashboards**
- Define key business metrics (tasks created/hour, users registered)
- Define key technical metrics (error rate, latency, throughput)
- Create multi-service dashboard
- Display SLI (Service Level Indicator) metrics

### **Day 5: SLO & Anomaly Detection**
- Define SLOs (e.g., 99.9% uptime, <200ms p99 latency)
- Calculate SLI from metrics
- Create CloudWatch Anomaly Detection
- Set alarms when SLO at risk

### **Day 6: OpsCenter & Runbooks**
- Create OpsCenter runbooks for:
  - High CPU alert → autoscale service
  - Database connection pool exhausted → connection pool reset
  - High error rate → check logs → auto-rollback if new deployment
- Test runbook execution
- Document manual steps for complex scenarios

### **Day 7: Incident Response & Documentation**
- Simulate production incident
- Execute incident response playbook
- Measure MTTR (Mean Time To Recovery)
- Document lessons learned
- Update runbooks based on findings

---

## Key Metrics to Monitor

**Availability:**
- Uptime percentage (99.9% = 43.2 min downtime/month)
- Error rate (< 0.1%)

**Performance:**
- Latency p50, p95, p99 (goal: <100ms p95)
- Throughput (requests/sec)
- Queue depth (SQS, Kafka)

**Business:**
- Requests per user
- Conversion funnel drop-off
- Revenue impact of incidents

---

## X-Ray Service Map Example

```
Internet
   ↓
ALB (10ms avg latency)
   ↓
User Service (50ms) ──→ RDS (40ms)
Task Service (75ms) ──→ RDS (60ms)
Auth Service (25ms) ──→ Cache (5ms)
```

Identify bottleneck: Task Service → RDS (slow queries)

---

**Next:** Week 12 - Enterprise Governance & Exam Prep
