# Week 6: Database Optimization & Scaling

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Performance (primary), Reliability (secondary)  
**Deliverable:** Optimized and scaled database with read replicas

---

## Week Overview

Optimize database performance (indexes, query optimization), implement read replicas for scaling reads, enable connection pooling, and plan Aurora migration. Measure query performance before/after optimization.

By end of week:
- ✅ RDS read replica in different AZ
- ✅ Connection pooling (PgBouncer)
- ✅ Query optimization and indexing
- ✅ Slow query logging and analysis
- ✅ Read-replica failover strategy documented
- ✅ Aurora compatibility plan

**Key Exam Concepts:**
1. Read replicas vs Multi-AZ (different purposes)
2. Connection pooling benefits and setup
3. RDS Proxy (managed connection pooling)
4. Query optimization (EXPLAIN ANALYZE)
5. Aurora Global Database (multi-region reads)

---

## Daily Breakdown

### **Day 1: Query Analysis & Optimization**
- Enable slow query logging (PostgreSQL)
- Run EXPLAIN ANALYZE on slow queries
- Create indexes on frequently queried columns
- Measure query performance improvement

### **Day 2: Create RDS Read Replica**
- Deploy read replica in us-east-1b
- Configure security group (allow replica)
- Test read-only connection
- Measure replication lag

### **Day 3: Connection Pooling (PgBouncer)**
- Deploy PgBouncer on application layer
- Configure connection pools
- Test connection reduction
- Monitor connection saturation

### **Day 4: RDS Proxy (AWS Managed)**
- Create RDS Proxy endpoint
- Update application to use proxy endpoint
- Measure connection efficiency
- Compare cost: PgBouncer vs RDS Proxy

### **Day 5: Replication Monitoring**
- Monitor replication lag
- Set up alarms for lag >5 seconds
- Test failover to read replica
- Document RTO/RPO for read replica

### **Day 6: Aurora Planning**
- Understand Aurora architecture vs RDS
- Plan migration from PostgreSQL to Aurora
- Test Aurora with test database
- Document rollback strategy

### **Day 7: Performance Testing & Documentation**
- Load test with read replicas
- Measure throughput improvement
- Document optimization techniques
- Create database scaling runbook

---

## Key Metrics

**Before optimization:**
- Query time: 500ms average
- DB connections: 80/100 max
- CPU: 60%

**After optimization (target):**
- Query time: 100ms average
- DB connections: 30/100 max
- CPU: 30%

---

## Aurora vs RDS Trade-offs

| Feature | RDS PostgreSQL | Aurora |
|---------|---|---|
| Cost per instance | $ | $$ |
| Read replica setup | Manual | Automatic |
| Failover speed | 2-3 min | 30 seconds |
| Global database | No | Yes |
| Serverless option | No | Yes |

---

**Next:** Week 7 - Multi-Region Architecture
