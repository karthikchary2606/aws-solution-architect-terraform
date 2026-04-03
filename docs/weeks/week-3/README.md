# Week 3: CI/CD Pipeline & GitOps

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Operational Excellence (primary)  
**Deliverable:** Automated build, test, and deployment pipeline

---

## Week Overview

Automate your infrastructure and application deployment using GitHub Actions (or GitLab CI) and Terraform. By end of week, pushing code to `main` branch automatically runs tests, builds Docker images, pushes to ECR, and deploys via Terraform.

By end of week, you'll have:
- ✅ GitHub Actions (or GitLab CI) pipeline for application
- ✅ Docker build and push to ECR
- ✅ Terraform deployment automation
- ✅ Automated testing (unit + integration)
- ✅ Deployment notifications
- ✅ Rollback strategy documented

**Key Exam Concepts:**
1. Infrastructure as Code and configuration management
2. Deployment patterns (rolling, blue/green, canary)
3. Infrastructure drift detection
4. Secrets management in CI/CD
5. Cost optimization through automation

---

## Daily Breakdown

### **Day 1: Design CI/CD Pipeline**
- Plan pipeline stages: Test → Build → Deploy
- Choose deployment strategy
- Document secrets management
- Design rollback procedures

### **Day 2: Create GitHub Actions Workflow**
- Set up repository secrets (AWS credentials, Docker credentials)
- Create workflow file `.github/workflows/deploy.yml`
- Test workflow on feature branch

### **Day 3: Automate Docker Build & ECR Push**
- Build Docker images for 3 microservices
- Push to ECR
- Tag images with git SHA + latest

### **Day 4: Automate Testing**
- Unit tests in CI
- Integration tests (containerized PostgreSQL)
- Code coverage reporting

### **Day 5: Terraform Automation**
- Run `terraform plan` on all PRs
- Show plan as comment on PR
- Auto-apply on main branch

### **Day 6: Deployment Notifications & Monitoring**
- Slack notifications on deployment
- Monitor deployment health
- Rollback if health checks fail

### **Day 7: Assessment & Practice**
- Trigger deployment via code push
- Test rollback scenario
- Document pipeline runbook

---

## Assessment Quiz

**15 questions covering:**
- CI/CD pipeline design patterns
- Terraform best practices in automation
- Secrets management
- Deployment strategies
- Rollback scenarios

**Next:** Week 4 - Caching Layer (ElastiCache + CloudFront)
