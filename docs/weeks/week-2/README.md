# Week 2: Microservices Decomposition & ECS

**Duration:** 7 days (12-15 hours total)  
**Exam Domains:** Reliability (50%), Operational Excellence (50%)  
**Deliverable:** Decomposed monolith into 3 services running on ECS Fargate

---

## Week Overview

This week you'll take your monolithic task-app and split it into independent microservices. You'll move from single EC2 instance to ECS Fargate cluster, learning how to manage multiple services, service discovery, and independent scaling.

By end of week, you'll have:
- ✅ 3 independent microservices (User Service, Task Service, Auth Service)
- ✅ ECS Fargate cluster with task definitions
- ✅ Service discovery with CloudMap
- ✅ API Gateway for unified entry point
- ✅ Cross-service communication
- ✅ Independent service scaling and deployment

**Key Exam Concepts to Master This Week:**
1. **Microservices Architecture** — When to split services, trade-offs
2. **ECS vs EKS** — Container orchestration options
3. **Service Discovery** — CloudMap, service mesh, DNS
4. **API Gateway** — Central routing, rate limiting, request transformation
5. **Stateless Design** — Why services must be stateless for scaling

---

## Daily Breakdown

### **Day 1: Service Decomposition Planning**
**Time:** 2-3 hours  
**Concepts:** Microservices design, bounded contexts, service boundaries

**Tasks:**
1. Review your monolithic application structure
   ```bash
   cd /Users/kkondoju/aws-solution-architect-labs
   ls -la
   # See: app/, frontend/, Dockerfile, docker-compose.yml
   
   # Review current endpoints
   grep -r "@app.get\|@app.post" app/
   ```

2. Understand your current architecture
   ```
   Single Monolith:
   ├─ /api/users (User Management)
   ├─ /api/tasks (Task Management)
   ├─ /api/auth (Authentication)
   └─ /api/admin (Admin Functions)
   ```

3. Identify service boundaries
   - **User Service:** User registration, profile, password management
   - **Task Service:** Task CRUD operations, task filtering, task assignments
   - **Auth Service:** JWT generation, token validation, OAuth (future)

4. Plan database strategy
   - **Shared database:** One RDS for all services (tight coupling)
   - **Database-per-service:** Each service has its own schema (loose coupling)
   - **Recommendation:** Shared database for Week 2 (simplicity), move to separate DBs in Week 6

5. Design API contracts (request/response formats)
   ```json
   // User Service
   GET /api/v1/users/{id}
   Response: { id, email, name, created_at }
   
   // Task Service
   GET /api/v1/tasks/{id}
   Response: { id, user_id, title, completed, created_at }
   
   // Auth Service
   POST /api/v1/auth/token
   Body: { email, password }
   Response: { access_token, token_type, expires_in }
   ```

6. Plan container strategy
   - One container per service
   - Separate Docker images
   - Shared PostgreSQL (for now)

7. Document architecture
   Create `architecture.md`:
   ```markdown
   # Week 2 Microservices Architecture
   
   ## Services
   
   ### User Service
   - Port: 8001
   - Endpoints: /users, /users/{id}, /profile
   - Database: Shared RDS (schema: users)
   
   ### Task Service
   - Port: 8002
   - Endpoints: /tasks, /tasks/{id}, /tasks/user/{user_id}
   - Database: Shared RDS (schema: tasks)
   
   ### Auth Service
   - Port: 8003
   - Endpoints: /token, /validate, /refresh
   - Database: Shared RDS (schema: none, read-only)
   
   ## API Gateway
   - Port: 80 (ALB)
   - Routes /api/users -> User Service:8001
   - Routes /api/tasks -> Task Service:8002
   - Routes /api/auth -> Auth Service:8003
   ```

**Learning Points:**
- Microservices trade-off: more operational complexity for independent scaling
- Why separate services? Different SLOs, different scaling needs, independent deployment
- Common mistake: Creating too many microservices too early (leads to complexity)

---

### **Day 2: Create ECS Infrastructure (Terraform)**
**Time:** 3-4 hours  
**Concepts:** ECS, Fargate, task definitions, IAM roles

**Tasks:**
1. Create ECS cluster Terraform module
   ```bash
   mkdir -p /Users/kkondoju/aws-solution-architect-terraform/modules/ecs
   ```

2. Create `modules/ecs/variables.tf`
   ```hcl
   variable "cluster_name" {
     type = string
   }
   
   variable "environment" {
     type = string
   }
   
   variable "tags" {
     type = map(string)
   }
   ```

3. Create `modules/ecs/main.tf`
   ```hcl
   # ECS Cluster
   resource "aws_ecs_cluster" "main" {
     name = var.cluster_name
   
     setting {
       name  = "containerInsights"
       value = "enabled"
     }
   
     tags = var.tags
   }
   
   # CloudWatch Logs for ECS
   resource "aws_cloudwatch_log_group" "ecs" {
     name              = "/ecs/${var.cluster_name}"
     retention_in_days = 7
     tags              = var.tags
   }
   ```

4. Create `modules/ecs/outputs.tf`
   ```hcl
   output "cluster_arn" {
     value = aws_ecs_cluster.main.arn
   }
   
   output "cluster_name" {
     value = aws_ecs_cluster.main.name
   }
   
   output "log_group_name" {
     value = aws_cloudwatch_log_group.ecs.name
   }
   ```

5. Update root `main.tf` to include ECS module
   ```hcl
   module "ecs" {
     source = "./modules/ecs"
     
     cluster_name = "${var.project_name}-cluster"
     environment  = var.environment
     tags         = local.common_tags
   }
   ```

6. Deploy
   ```bash
   terraform plan
   terraform apply
   ```

7. Verify in AWS Console
   - Go to ECS → Clusters
   - See your new cluster (task-app-cluster)

**Learning Points:**
- ECS cluster is logical grouping, not actual EC2 instances
- Fargate is serverless container runtime (no EC2 to manage)
- Container Insights = CloudWatch monitoring for containers

---

### **Day 3: Create ECS Task Definitions**
**Time:** 3-4 hours  
**Concepts:** Task definitions, container definitions, logging, networking

**Tasks:**
1. Create task definition for User Service
   ```bash
   mkdir -p /Users/kkondoju/aws-solution-architect-terraform/modules/ecs-task
   ```

2. Create `modules/ecs-task/variables.tf`
   ```hcl
   variable "family" {
     type = string  # e.g., "task-app-user"
   }
   
   variable "container_name" {
     type = string
   }
   
   variable "image" {
     type = string  # Docker image URI
   }
   
   variable "port" {
     type = number
   }
   
   variable "environment" {
     type = map(string)
   }
   
   variable "log_group" {
     type = string
   }
   ```

3. Create `modules/ecs-task/main.tf`
   ```hcl
   resource "aws_ecs_task_definition" "main" {
     family                   = var.family
     network_mode             = "awsvpc"
     requires_compatibilities = ["FARGATE"]
     cpu                      = 256
     memory                   = 512
     execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
     task_role_arn            = aws_iam_role.ecs_task_role.arn
   
     container_definitions = jsonencode([{
       name      = var.container_name
       image     = var.image
       essential = true
       portMappings = [{
         containerPort = var.port
         hostPort      = var.port
         protocol      = "tcp"
       }]
       environment = [for k, v in var.environment : {
         name  = k
         value = v
       }]
       logConfiguration = {
         logDriver = "awslogs"
         options = {
           "awslogs-group"         = var.log_group
           "awslogs-region"        = "us-east-1"
           "awslogs-stream-prefix" = var.container_name
         }
       }
     }])
   }
   ```

4. Create IAM roles for ECS tasks
   ```hcl
   # Execution role (pulls images, logs)
   resource "aws_iam_role" "ecs_task_execution_role" {
     name = "${var.family}-execution-role"
   
     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect = "Allow"
         Principal = {
           Service = "ecs-tasks.amazonaws.com"
         }
         Action = "sts:AssumeRole"
       }]
     })
   }
   
   resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
     role       = aws_iam_role.ecs_task_execution_role.name
     policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
   }
   
   # Task role (permissions for container to call AWS APIs)
   resource "aws_iam_role" "ecs_task_role" {
     name = "${var.family}-task-role"
   
     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect = "Allow"
         Principal = {
           Service = "ecs-tasks.amazonaws.com"
         }
         Action = "sts:AssumeRole"
       }]
     })
   }
   ```

5. Create task definitions for all 3 services
   - Repeat for Task Service (port 8002)
   - Repeat for Auth Service (port 8003)

6. Deploy task definitions
   ```bash
   terraform plan
   terraform apply
   ```

7. Verify in AWS Console
   - ECS → Task Definitions
   - See 3 task definitions registered

**Learning Points:**
- Task definition = template for running a container
- awsvpc = containers get elastic network interfaces
- Execution role = ECS platform permissions (pull ECR images, CloudWatch logs)
- Task role = Container permissions (DynamoDB, S3, etc.)

---

### **Day 4: Create ECS Services & Service Discovery**
**Time:** 3-4 hours  
**Concepts:** ECS Services, autoscaling, CloudMap service discovery

**Tasks:**
1. Create ECS Service module
   ```bash
   mkdir -p /Users/kkondoju/aws-solution-architect-terraform/modules/ecs-service
   ```

2. Create `modules/ecs-service/main.tf`
   ```hcl
   # ECS Service
   resource "aws_ecs_service" "main" {
     name            = var.service_name
     cluster         = var.cluster_name
     task_definition = var.task_definition_arn
     desired_count   = var.desired_count
     launch_type     = "FARGATE"
   
     network_configuration {
       subnets          = var.subnet_ids
       security_groups  = [aws_security_group.ecs_task.id]
       assign_public_ip = false
     }
   
     # Load balancer attachment
     load_balancer {
       target_group_arn = var.target_group_arn
       container_name   = var.container_name
       container_port   = var.container_port
     }
   
     # Service discovery
     service_registries {
       registry_arn = aws_service_discovery_service.main.arn
     }
   
     depends_on = [var.alb_listener_arn]
   }
   
   # Service Discovery (CloudMap)
   resource "aws_service_discovery_service" "main" {
     name = var.service_name
   
     dns_config {
       namespace_id = var.service_discovery_namespace_id
       dns_records {
         ttl  = 10
         type = "A"
       }
       routing_policy = "MULTIVALUE"
     }
   
     health_check_custom_config {
       failure_threshold = 1
     }
   }
   
   # Security group for ECS tasks
   resource "aws_security_group" "ecs_task" {
     name   = "${var.service_name}-task"
     vpc_id = var.vpc_id
   
     ingress {
       from_port       = var.container_port
       to_port         = var.container_port
       protocol        = "tcp"
       security_groups = [var.alb_security_group_id]
     }
   
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
   ```

3. Create service discovery namespace
   ```hcl
   resource "aws_service_discovery_private_dns_namespace" "main" {
     name = var.service_discovery_namespace
     vpc  = var.vpc_id
   }
   ```

4. Create 3 ECS services (one per microservice)
   - User Service: port 8001
   - Task Service: port 8002
   - Auth Service: port 8003

5. Deploy
   ```bash
   terraform plan
   terraform apply
   ```

6. Verify services in AWS Console
   - ECS → Clusters → task-app-cluster → Services
   - See 3 services running

**Learning Points:**
- ECS Service = How many tasks to run and where
- Service Discovery = Register tasks in DNS so services can find each other
- CloudMap = AWS's service discovery solution (alternative: Consul, Eureka)
- Service-to-service communication: `user-service.service-discovery:8001`

---

### **Day 5: Update ALB for Microservices Routing**
**Time:** 2-3 hours  
**Concepts:** Path-based routing, target groups, API Gateway

**Tasks:**
1. Update ALB configuration
   ```hcl
   # Add listener rules for path-based routing
   resource "aws_lb_listener_rule" "api_users" {
     listener_arn = aws_lb_listener.http.arn
     priority     = 100
   
     action {
       type             = "forward"
       target_group_arn = var.user_service_target_group_arn
     }
   
     condition {
       path_pattern {
         values = ["/api/users*"]
       }
     }
   }
   
   resource "aws_lb_listener_rule" "api_tasks" {
     listener_arn = aws_lb_listener.http.arn
     priority     = 101
   
     action {
       type             = "forward"
       target_group_arn = var.task_service_target_group_arn
     }
   
     condition {
       path_pattern {
         values = ["/api/tasks*"]
       }
     }
   }
   
   resource "aws_lb_listener_rule" "api_auth" {
     listener_arn = aws_lb_listener.http.arn
     priority     = 102
   
     action {
       type             = "forward"
       target_group_arn = var.auth_service_target_group_arn
     }
   
     condition {
       path_pattern {
         values = ["/api/auth*"]
       }
     }
   }
   ```

2. Deploy updated ALB configuration
   ```bash
   terraform plan
   terraform apply
   ```

3. Test routing
   ```bash
   ALB_DNS=$(terraform output alb_dns_name)
   
   # Test each service
   curl http://$ALB_DNS/api/users       # Should hit User Service
   curl http://$ALB_DNS/api/tasks       # Should hit Task Service
   curl http://$ALB_DNS/api/auth/token  # Should hit Auth Service
   ```

4. Verify in CloudWatch
   - Open ALB metrics
   - See requests distributed to each target group

**Learning Points:**
- Path-based routing = distribute requests based on URL pattern
- Host-based routing = distribute based on hostname (good for multi-tenant)
- Priority matters (lowest priority number matches first)

---

### **Day 6: Test Service Communication & Failover**
**Time:** 2-3 hours  
**Concepts:** Service discovery, failover, independent scaling

**Tasks:**
1. Test service-to-service communication
   - Log into Task Service container
   - Curl User Service at: `http://user-service.service-discovery:8001/api/users`

2. Scale a service
   ```bash
   # Scale Task Service to 3 instances
   aws ecs update-service \
     --cluster task-app-cluster \
     --service task-service \
     --desired-count 3
   
   # Watch tasks launch
   aws ecs list-tasks --cluster task-app-cluster
   ```

3. Monitor CloudWatch
   - See 3 tasks for Task Service
   - See requests distributed across all 3

4. Test failure scenarios
   - Terminate one task
   - ECS automatically launches replacement
   - Service continues with zero downtime

5. Monitor logs
   ```bash
   aws logs tail /ecs/task-app-cluster --follow
   ```

**Learning Points:**
- Service discovery enables service-to-service calls
- Each task gets unique IP, but CloudMap handles discovery
- ECS auto-replaces failed tasks (if desired_count > current)

---

### **Day 7: Assessment & Review**
**Time:** 2-3 hours  
**Activity:** Assessment quiz, document learnings, prepare for Week 3

**Assessment:**
1. **Architecture Quiz:**
   - Draw your microservices architecture
   - Identify service boundaries
   - Explain why services are decoupled

2. **Failover Test:**
   - Terminate Task Service task
   - Measure time to recovery
   - Document in runbook

3. **Load Test:**
   - Generate requests to all 3 services
   - Monitor metrics
   - Calculate throughput per service

4. **Documentation:**
   - Document service discovery addresses
   - Create runbook for scaling a service
   - Document API contract changes

**Review Checklist:**
- [ ] 3 microservices deployed to ECS
- [ ] Service discovery working (service-to-service communication)
- [ ] ALB routing to correct services
- [ ] Services can scale independently
- [ ] Failure in one service doesn't take down others
- [ ] CloudWatch logs aggregating all service logs
- [ ] Assessment completed with 80%+ score

---

## Common Gotchas & Fixes

| Problem | Cause | Solution |
|---------|-------|----------|
| Containers can't find each other | Service discovery namespace missing | Check CloudMap private DNS namespace exists |
| Task won't start | Image not in ECR | Push Docker images to ECR before deploying |
| ALB showing unhealthy targets | Wrong port in security group | Verify SG allows container port from ALB SG |
| Tasks fail to start immediately | Memory/CPU insufficient | Increase task CPU/memory in task definition |
| Service discovery DNS not working | Cached DNS | Flush DNS cache or restart containers |

---

**End of Week 2**

Next: `docs/weeks/week-3/README.md` — CI/CD Pipeline & GitOps

Your microservices foundation is ready! 🚀
