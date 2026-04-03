# Week 1: VPC, EC2, RDS — 3-Tier Foundation

**Duration:** 7 days (10-15 hours total)  
**Exam Domains:** Reliability (60%), Operational Excellence (40%)  
**Deliverable:** Deployed and monitored 3-tier application on AWS

---

## Week Overview

This week you'll take the completed Terraform modules and actually deploy a production-ready 3-tier architecture. You'll learn how VPC design affects reliability, why multi-AZ matters, and how to monitor your infrastructure using CloudWatch.

By end of week, you'll have:
- ✅ VPC with proper subnet segmentation (public ALB subnets, private app subnet, isolated DB subnets)
- ✅ RDS PostgreSQL multi-AZ with automated backups
- ✅ EC2 instance running containerized application
- ✅ Application Load Balancer with health checks
- ✅ CloudWatch monitoring, alarms, and dashboard
- ✅ Test failover and measure RTO

**Key Exam Concepts to Master This Week:**
1. **VPC Design** — Why isolate subnets? What's the difference between public/private/isolated?
2. **Multi-AZ Architecture** — Trade-off between availability and latency; RTO/RPO impact
3. **Security Groups as Firewalls** — Ingress/egress rules; principle of least privilege
4. **Load Balancer Health Checks** — How it knows when an instance is dead; connection draining
5. **RDS Monitoring** — Key metrics (CPU, connections, storage); backup windows; failover behavior
6. **Infrastructure as Code** — Terraform state management, remote backends, why teams use Terraform Cloud

---

## Daily Breakdown

### **Day 1: Setup & Infrastructure Planning**
**Time:** 2-3 hours  
**Concepts:** Terraform fundamentals, AWS authentication, state management

**Tasks:**
1. Verify AWS CLI credentials
   ```bash
   aws sts get-caller-identity
   ```
   Expected output: Your AWS account ID, user ARN

2. Authenticate with Terraform Cloud
   ```bash
   terraform login
   # Paste your API token when prompted
   ```

3. Review your infrastructure diagram (see ROADMAP.md)
   - Draw out your VPC: subnets, routing, security groups
   - Understand why ALB is in public subnets but app is in private subnets
   - Why is RDS completely isolated in DB subnets?

4. Review your Terraform code structure
   ```bash
   cd /Users/kkondoju/aws-solution-architect-terraform
   
   # Explore the modules
   ls -la modules/
   # Output: alb/  ec2/  monitoring/  rds/  vpc/
   
   # Check state backend config
   cat terraform.tf  # Look for backend "cloud" block
   ```

5. Create EC2 key pair (if you haven't)
   ```bash
   aws ec2 create-key-pair \
     --key-name your-key-pair \
     --region us-east-1 \
     --query 'KeyMaterial' \
     --output text > ~/your-key-pair.pem
   
   chmod 600 ~/your-key-pair.pem
   ```

6. Customize terraform.tfvars
   - Open `terraform.tfvars`
   - Change `db_password` to a strong, random password
   - Change `jwt_secret` to random string: `openssl rand -hex 32`
   - Change `key_pair_name` to your created key pair
   - Save

**Learning Points:**
- Why use Terraform Cloud instead of local state? (Team collaboration, security, auditability)
- What's in terraform.tf? (Provider, backend, remote state configuration)
- What does each subnet CIDR represent?

**Quiz Questions (check answers in assessment.md):**
1. If you have `vpc_cidr = "10.0.0.0/16"`, how many usable IPs does your VPC have? (Hint: AWS reserves 5 per subnet)
2. Why would you NOT put your RDS database in the same subnet as your application?
3. What happens if you lose your Terraform state file?

---

### **Day 2: Deploy Infrastructure with Terraform**
**Time:** 3-4 hours (includes 10-15 min wait for RDS provisioning)  
**Concepts:** Terraform workflow (init → validate → plan → apply), state management

**Tasks:**
1. Initialize Terraform
   ```bash
   cd /Users/kkondoju/aws-solution-architect-terraform
   terraform init
   # Output: Terraform has been successfully configured!
   # State will be stored in Terraform Cloud under evoketechnologies/prod
   ```

2. Validate Terraform syntax
   ```bash
   terraform validate
   # Output: Success! The configuration is valid.
   ```

3. Plan your infrastructure
   ```bash
   terraform plan -out=tfplan
   # This creates a file 'tfplan' that you'll apply
   # Read the output carefully:
   #   - How many resources will be created?
   #   - Any unexpected changes?
   ```

4. Review the plan output
   - Count resources:
     - VPC: 1
     - Subnets: 6 (app, ALB x2, DB x2)
     - Security Groups: 3 (ALB, app, database)
     - Internet Gateway: 1
     - Route Tables: 1
     - RDS Instance: 1
     - EC2 Instance: 1
     - ALB: 1
     - Target Group: 1
     - CloudWatch: Log group, alarms, dashboard
   
   - Expected total: 18-20 resources

5. Apply the plan
   ```bash
   terraform apply tfplan
   # This takes 12-15 minutes (mostly RDS startup)
   # You'll see:
   # aws_vpc.main: Creating...
   # aws_security_group.alb: Creating...
   # ... (many resources)
   # aws_db_instance.main: Creating... (this takes the longest)
   ```

6. Monitor apply progress
   - Open AWS Console → RDS → Databases
   - Watch the "Status" column: "Creating" → "Modifying" → "Available"
   - Once "Available", RDS is ready

7. After apply completes, get outputs
   ```bash
   terraform output
   # You'll see:
   # alb_dns_name = "task-app-alb-123456.us-east-1.elb.amazonaws.com"
   # ec2_public_ip = "54.123.45.67"
   # rds_endpoint = "task-app-db.xxxxx.us-east-1.rds.amazonaws.com"
   # ... (more outputs)
   
   # Save these values! You'll need them
   ```

**Troubleshooting:**
- **"Error: API rate limiting"** → Wait 5 minutes, then `terraform apply tfplan` again
- **"Error: Insufficient capacity"** → Try a different AZ or instance type (edit tfvars and re-apply)
- **"Error: RDS still creating"** → Terraform correctly waits for RDS. Be patient. (15 min is normal)

**Learning Points:**
- What is a `.tfplan` file? (Pre-calculated plan to prevent surprises during apply)
- Why does Terraform wait for RDS before finishing?
- What's stored in Terraform Cloud state? (Sensitive values like passwords are encrypted)

---

### **Day 3: Deploy Application to EC2**
**Time:** 2-3 hours  
**Concepts:** Docker, containerization, application deployment, environment variables

**Tasks:**
1. SSH into your EC2 instance
   ```bash
   # Get the EC2 public IP from terraform output
   PUBLIC_IP=$(terraform output -raw ec2_public_ip)
   
   ssh -i ~/your-key-pair.pem ec2-user@$PUBLIC_IP
   # You should now be on the EC2 instance
   ```

2. Verify Docker and Docker Compose are installed
   ```bash
   docker --version
   # Output: Docker version 24.x.x
   
   docker-compose --version
   # Output: Docker Compose version 2.x.x
   ```

3. Examine the docker-compose.yml that was created by user data
   ```bash
   cat /opt/task-app/docker-compose.yml
   # You'll see a full docker-compose setup with PostgreSQL, FastAPI, Nginx
   ```

4. Check application logs
   ```bash
   cd /opt/task-app
   docker-compose logs -f
   # Watch the logs for:
   # fastapi_1  | INFO:     Application startup complete
   # This means the app started successfully
   ```

5. Get the RDS endpoint from your local terminal (not SSH'd in)
   ```bash
   RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
   echo $RDS_ENDPOINT
   ```

6. SSH back in and verify database connectivity from the container
   ```bash
   # From within the EC2 SSH session
   docker-compose exec fastapi psql -h $RDS_ENDPOINT -U dbadmin -d taskdb -c "SELECT version();"
   # You should see the PostgreSQL version
   ```

7. Create database tables
   ```bash
   # Still in SSH session
   docker-compose exec fastapi python -c "from app.database import engine; from app.models import Base; Base.metadata.create_all(bind=engine)"
   # This creates User and Task tables
   ```

8. Verify tables were created
   ```bash
   docker-compose exec fastapi psql -h $RDS_ENDPOINT -U dbadmin -d taskdb -c "\dt"
   # Output should show: public | users | table
   #                     public | tasks | table
   ```

9. Exit SSH session
   ```bash
   exit
   ```

**Verification:**
- Application is running (no errors in docker-compose logs)
- Database is accessible from application container
- Tables are created

**Learning Points:**
- Why run PostgreSQL in a container for dev but RDS for production?
- How does Docker Compose discover the RDS endpoint? (It's passed as environment variable)
- What would happen if your EC2 instance rebooted? (Docker Compose would restart automatically)

**Quiz:**
1. If docker-compose logs shows "Connection refused to RDS endpoint", what are 3 possible causes?
2. Your app container can't connect to RDS. The RDS instance is available. What should you check?

---

### **Day 4: Configure and Test ALB (Application Load Balancer)**
**Time:** 2-3 hours  
**Concepts:** Load balancing, target groups, health checks, sticky sessions

**Tasks:**
1. Get your ALB DNS name
   ```bash
   ALB_DNS=$(terraform output -raw alb_dns_name)
   echo "Your application is at: http://$ALB_DNS"
   ```

2. Open the application in your browser
   ```
   http://<ALB_DNS>
   ```
   You should see the task-app dashboard login page.

3. Test the application
   - Register a new user (any email, password)
   - Log in with that user
   - Create a few tasks
   - Mark tasks complete
   - Everything should work through the ALB

4. Check ALB target group health
   ```bash
   # In your local terminal (AWS CLI)
   aws elbv2 describe-target-health \
     --target-group-arn $(terraform output -raw target_group_arn) \
     --region us-east-1
   
   # Output should show:
   # "TargetHealth": {
   #   "State": "healthy",
   #   "Reason": "Health checks succeeded"
   # }
   ```

5. Understand health check behavior
   - ALB checks `/health` endpoint every 30 seconds
   - If health check fails 3 times (90 seconds), target marked unhealthy
   - ALB stops sending traffic to unhealthy targets
   - Review your fastapi app's `/health` endpoint in `app/main.py`

6. Monitor ALB metrics in CloudWatch
   ```bash
   # Open AWS Console → CloudWatch → Metrics
   # Search for "ApplicationELB"
   # View:
   # - TargetResponseTime (should be <100ms)
   # - RequestCount (how many requests hitting ALB)
   # - HealthyHostCount (should be 1)
   # - UnHealthyHostCount (should be 0)
   ```

7. Test failure scenario: Stop the application
   ```bash
   # SSH into EC2
   ssh -i ~/your-key-pair.pem ec2-user@$(terraform output -raw ec2_public_ip)
   
   # Stop docker-compose
   cd /opt/task-app
   docker-compose stop
   
   # Watch ALB mark target unhealthy
   # (Takes ~90 seconds for health check to fail 3 times)
   ```

8. Restart application
   ```bash
   docker-compose up -d
   # ALB will mark target healthy again after health check passes
   ```

9. Exit SSH
   ```bash
   exit
   ```

**Learning Points:**
- How ALB knows when your instance is down (health checks)
- Connection draining (ALB waits for in-flight requests to finish before removing target)
- Why multiple instances → ALB distributes traffic across them

**Quiz:**
1. Your health check is set to check every 30 seconds with 3 failure threshold. What's the maximum time before ALB marks your instance unhealthy?
2. If you want your ALB to route all requests from the same user to the same backend, what feature do you enable?

---

### **Day 5: CloudWatch Monitoring & Alarms**
**Time:** 2-3 hours  
**Concepts:** Monitoring, metrics, alarms, dashboards, observability

**Tasks:**
1. Review your CloudWatch dashboard
   ```bash
   # Get dashboard URL
   terraform output cloudwatch_dashboard_url
   # Open the URL in your browser
   ```

2. Understand the dashboard widgets
   - **System Metrics:** EC2 CPU, RDS CPU, RDS Database Connections
   - **ALB Metrics:** Response time, request count, 2XX responses

3. Generate load to see metrics change
   ```bash
   # SSH into EC2 and start a load test
   ssh -i ~/your-key-pair.pem ec2-user@$(terraform output -raw ec2_public_ip)
   
   cd /opt/task-app
   
   # Generate some requests (simple loop)
   while true; do
     curl -s http://localhost:8000/health > /dev/null
     sleep 1
   done
   # Let this run for 2-3 minutes, then Ctrl+C
   ```

4. Watch metrics update in real-time
   - Go back to CloudWatch dashboard
   - You should see RequestCount increase
   - TargetResponseTime might increase slightly

5. Review alarm configurations
   ```bash
   # AWS Console → CloudWatch → Alarms
   # You should see 4 alarms created by Terraform:
   # 1. task-app-ec2-cpu-high (threshold: 80%)
   # 2. task-app-rds-cpu-high (threshold: 80%)
   # 3. task-app-rds-connections-high (threshold: 80)
   # 4. task-app-alb-unhealthy-hosts (threshold: >= 1)
   ```

6. Test an alarm
   ```bash
   # SSH into EC2
   ssh -i ~/your-key-pair.pem ec2-user@$(terraform output -raw ec2_public_ip)
   
   # Create high CPU load
   stress --cpu 1 --timeout 300s
   # (if stress not installed: sudo yum install -y stress)
   
   # Watch CloudWatch:
   # - CPU metric should spike above 80%
   # - Alarm should change from OK → ALARM
   ```

7. Understanding alarms in production
   - These alarms would trigger SNS notifications (you'd add email subscribers in real project)
   - Alarms trigger auto-scaling policies (you'll implement in Week 7)
   - Alarms are data for incident response

8. Exit stress test and SSH
   ```bash
   # Ctrl+C on stress command
   exit
   ```

**Exam Concept - RTO/RPO:**
- **RTO (Recovery Time Objective):** How long can your service be down? 
  - Your ALB detects failure in 90 seconds → RTO ≈ 2 minutes (single instance failure)
- **RPO (Recovery Point Objective):** How much data can you lose?
  - RDS backups every night → RPO ≈ 24 hours

**Learning Points:**
- Metrics vs Alarms: metrics are observations, alarms are thresholds
- CloudWatch retention: metrics kept for 15 months by default
- Custom metrics: you can publish custom metrics from your application

---

### **Day 6: Multi-AZ Failover Testing**
**Time:** 2-3 hours  
**Concepts:** Availability, failover, RTO, redundancy

**Tasks:**
1. Understand your current architecture
   ```
   Your 3-tier app:
   - ALB: Spread across 2 AZs (redundant at ALB level)
   - EC2: Single instance in us-east-1a (single point of failure!)
   - RDS: Multi-AZ enabled (primary in us-east-1a, standby in us-east-1b)
   ```

2. Test RDS Multi-AZ failover
   - Go to AWS Console → RDS → Databases
   - Select "task-app-db" instance
   - Click "Actions" → "Reboot"
   - Check "Reboot with failover" checkbox
   - This triggers failover to standby in different AZ

3. Monitor the failover
   - Watch Status: "Available" → "Rebooting" → "Available"
   - Check how long it takes (typically 1-3 minutes)
   - This is your RDS RTO

4. Verify application still works
   ```bash
   # In another terminal, continuously ping your ALB
   while true; do
     curl -s http://<ALB_DNS>/health
     date
   done
   # During failover, you might see 1-2 failed requests, then it recovers
   ```

5. Check RDS failover details
   - Get new RDS endpoint (it might have changed)
   ```bash
   terraform output rds_endpoint
   ```
   - RDS endpoint didn't change! (DNS alias updated automatically)
   - This is why you never hardcode RDS IPs

6. Simulate EC2 instance failure
   ```bash
   # Terminate the EC2 instance in AWS Console
   # AWS Console → EC2 → Instances → Select your instance → Instance State → Terminate
   ```

7. Watch what happens
   - ALB health checks fail (no instance to check)
   - ALB marks target unhealthy
   - Application becomes unavailable
   - This is your RTO for single instance: ∞ (until you replace it)

8. Restore from Terraform
   ```bash
   # Since you defined EC2 in Terraform, it's easy to restore
   terraform apply -auto-approve
   # Terraform will recreate the instance
   # Takes ~2 minutes
   # Application comes back online
   ```

**Learning Points:**
- RDS Multi-AZ: Automatic failover, no action required, minutes of downtime
- EC2 Single Instance: No automatic failover, manual recovery required, hours of downtime
- This is why Week 2 focuses on ECS (auto-scaling and replacement)

**Exam Scenario:**
"Your RDS instance fails. What's the impact to your application?"
- Answer: Depends on Multi-AZ enabled. If yes: 1-3 minutes of unavailability, automatic failover. If no: manual recovery, potential data loss.

---

### **Day 7: Assessment & Review**
**Time:** 2-3 hours  
**Activity:** Complete assessment, review weak areas, document learnings

**Assessment Quiz:** See `assessment.md` in this directory

**Review Checklist:**
- [ ] VPC created with proper subnet isolation (public, private, isolated)
- [ ] RDS multi-AZ enabled and tested failover
- [ ] EC2 running application with RDS connectivity
- [ ] ALB routing traffic with health checks working
- [ ] CloudWatch monitoring all key metrics
- [ ] Alarms configured and tested
- [ ] RTO/RPO documented for your architecture
- [ ] Assessment quiz completed with 80%+ score

**Document Your Learnings:**
Create a file `my-week-1-notes.md` and capture:
1. **Biggest learning:** What surprised you about VPC/RDS/ALB design?
2. **Trickiest concept:** What was hardest to understand?
3. **Architectural insight:** What trade-offs did you see?
4. **Exam focus:** Which concepts will you emphasize in your studies?

**Preparation for Week 2:**
- RDS and VPC are solid baseline
- Next week: Scale to microservices (multiple services instead of monolith)
- Prepare to decompose your single application into 3-4 services

---

## Common Gotchas & Fixes

| Problem | Cause | Solution |
|---------|-------|----------|
| ALB says target unhealthy | EC2 instance not running / health check endpoint broken | SSH in, check `docker-compose logs`, verify `/health` returns 200 |
| Can't connect to RDS from EC2 | Security group rules wrong | Check EC2 SG allows outbound 5432, RDS SG allows inbound from EC2 SG |
| RDS taking 15+ minutes | Normal | RDS multi-AZ setup takes time. Get coffee, don't cancel |
| terraform apply fails with "already exists" | Resource exists in AWS but not in state | Run `terraform import` or delete from AWS console and retry |
| Terraform Cloud state out of sync | Manual changes to AWS (via console) | Run `terraform refresh` to sync, then `terraform plan` |

---

## Key Takeaways

1. **VPC Design Matters:** Subnet isolation is your first line of defense
2. **Multi-AZ is Critical:** Single instances = single point of failure
3. **Health Checks Save You:** ALB detects failures automatically
4. **Infrastructure as Code:** Terraform makes recovery reproducible
5. **Monitoring is Proactive:** CloudWatch alarms alert before users complain

---

**End of Week 1**

Next: `docs/weeks/week-2/README.md` — Decompose into Microservices
