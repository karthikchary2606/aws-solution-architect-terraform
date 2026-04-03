# Week 4: Caching Layer (ElastiCache + CloudFront)

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Performance (primary), Cost Optimization (secondary)  
**Deliverable:** Caching layer with Redis + CloudFront CDN

---

## Week Overview

Add caching to reduce database load and latency. Implement Redis (ElastiCache) for session and data caching. Deploy CloudFront CDN for static assets. Monitor cache hit ratios and measure performance improvement.

By end of week:
- ✅ ElastiCache Redis cluster deployed
- ✅ Application updated for session caching
- ✅ CloudFront distribution for static assets
- ✅ Cache invalidation strategy
- ✅ Performance metrics and dashboards
- ✅ Cost savings measured

**Key Exam Concepts:**
1. Redis vs Memcached (when to use each)
2. Cache invalidation patterns
3. CloudFront behaviors and caching
4. Cache-Control headers and TTL
5. Cache stampede prevention

---

## Daily Breakdown

### **Day 1: Design Caching Strategy**
- Identify cacheable data (sessions, user profiles, task lists)
- Design cache key namespace
- Plan invalidation strategy
- Calculate cost vs performance trade-off

### **Day 2: Deploy ElastiCache Redis**
- Create Redis cluster (Terraform module)
- Configure security groups
- Create cluster subnet group
- Enable automated backups

### **Day 3: Update Application for Redis**
- Implement session caching (user authentication)
- Cache user profiles (expensive DB queries)
- Cache task lists with TTL
- Add cache hit/miss metrics

### **Day 4: Deploy CloudFront Distribution**
- Create S3 bucket for static assets
- Configure CloudFront distribution
- Set cache behaviors (images, CSS, JS)
- Configure origin shields for cost optimization

### **Day 5: Cache Management & Invalidation**
- Implement cache invalidation on data updates
- Test cache behavior with curl (Cache-Control headers)
- Monitor cache hit ratio in CloudFront metrics
- Document cache key design

### **Day 6: Performance & Cost Testing**
- Load test: measure latency before/after caching
- Measure database connection reduction
- Calculate monthly cost savings
- Document performance improvements

### **Day 7: Assessment & Documentation**
- Measure 50%+ improvement in response time
- Verify cache hit ratio >80%
- Document caching architecture
- Create cache debugging runbook

---

## Common Patterns

**Cache key design:**
```
users:{user_id}
tasks:{task_id}
user:tasks:{user_id}
```

**Cache invalidation:**
- TTL-based (10 min for user data, 1h for task lists)
- Event-based (invalidate on update)
- Manual (admin commands)

**CloudFront caching:**
- Images/static: 365 days
- CSS/JS: 30 days
- HTML: 5 minutes

---

## Assessment Quiz

15 questions on:
- Cache invalidation strategies
- CloudFront vs application caching
- Redis data structures for caching
- Cache performance optimization
- Cost-benefit analysis

---

**Next:** Week 5 - Encryption, Secrets, IAM
