Lifecycle Meta-arguments Explained in Terraform

lifecycle is a meta-argument that controls how Terraform creates, updates, or destroys resources.

Syntax:

resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  lifecycle {
    # lifecycle settings
  }
}
1. create_before_destroy

By default, Terraform destroys the old resource first and then creates the new one.

This can cause downtime.

Example without create_before_destroy

You change:

instance_type = "t3.medium"

to:

instance_type = "t3.large"

If replacement is required:

Destroy old EC2
Create new EC2

Application downtime occurs.

Using create_before_destroy
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  lifecycle {
    create_before_destroy = true
  }
}

Terraform flow:

Create new EC2
↓
Switch dependencies
↓
Destroy old EC2
Real-time use cases
ALB Target Groups
ECS Services
Auto Scaling Groups
Production databases (carefully)
Blue/Green deployments
2. prevent_destroy

Prevents accidental deletion of critical resources.

resource "aws_db_instance" "prod" {

  lifecycle {
    prevent_destroy = true
  }
}

If someone runs:

terraform destroy

Terraform returns:

Error: Instance cannot be destroyed
Real Production Examples

Protect:

Production RDS
S3 buckets containing backups
Route53 zones
KMS keys
ECR repositories

Example:

resource "aws_s3_bucket" "backups" {

  lifecycle {
    prevent_destroy = true
  }
}
3. ignore_changes

Tell Terraform to ignore changes to specific attributes.

Very commonly asked in interviews.

Example 1: Ignore Auto Scaling Changes
resource "aws_autoscaling_group" "app" {

  desired_capacity = 2

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

Suppose:

Terraform created ASG with 2 instances.
Scaling policy changes it to 6.

Terraform plan:

No changes.

Otherwise Terraform would try to revert it back to 2.

Example 2: Ignore ECS Desired Count
resource "aws_ecs_service" "app" {

  desired_count = 2

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

Real scenario:

Terraform deploys service with 2 tasks.
Auto Scaling increases to 10 tasks.

Terraform should not scale it back.

This is extremely common in ECS production environments.

Example 3: Ignore Tags Added by Security Team
lifecycle {
  ignore_changes = [
    tags
  ]
}

Useful when:

AWS Organizations
Service Catalog
External tagging tools add tags.
Ignore Everything (rare)
lifecycle {
  ignore_changes = all
}

Terraform will no longer manage updates.

Generally not recommended.

4. replace_triggered_by

Force recreation when another resource changes.

Example
resource "aws_instance" "app" {

  lifecycle {
    replace_triggered_by = [
      aws_security_group.app
    ]
  }
}

If SG changes:

EC2 instance replaced.
Real ECS Example
resource "aws_ecs_service" "app" {

  lifecycle {
    replace_triggered_by = [
      aws_ecs_task_definition.app
    ]
  }
}

Whenever a new task definition revision is created, ECS service gets updated.

Combined Example
resource "aws_ecs_service" "app" {

  desired_count = 2

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      desired_count
    ]
  }
}
Real Production Example (ECS)
resource "aws_ecs_service" "payments" {

  name            = "payments"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.payments.arn

  desired_count = 2

  lifecycle {
    ignore_changes = [
      desired_count
    ]

    create_before_destroy = true
  }
}

This allows:

✅ ECS Auto Scaling to manage task count
✅ Zero-downtime deployments
✅ Terraform still manages infrastructure.

Interview Questions
Q1. Why use ignore_changes?

To prevent Terraform from reverting changes made externally (Auto Scaling, AWS-managed updates, operators).

Q2. Where have you used lifecycle in real projects?

Examples:

prevent_destroy → Production RDS
ignore_changes → ECS desired count
create_before_destroy → ALB target groups and ECS deployments
replace_triggered_by → Task definition updates
Summary
Lifecycle Argument	Purpose	Real Example
create_before_destroy	Avoid downtime	ECS, ALB
prevent_destroy	Protect critical resources	RDS, KMS
ignore_changes	Ignore external updates	ECS scaling, ASG
replace_triggered_by	Force recreation on dependency changes	ECS task definition