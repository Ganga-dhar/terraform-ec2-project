# Terraform Lifecycle Meta-arguments Explained

`lifecycle` is a meta-argument that controls how Terraform creates, updates, or destroys resources.

## Syntax

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  lifecycle {
    # lifecycle settings
  }
}
```

## 1. create_before_destroy

Creates the replacement resource before destroying the existing one to avoid downtime.

### Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  lifecycle {
    create_before_destroy = true
  }
}
```

### Use Cases
- ECS Services
- ALB Target Groups
- Auto Scaling Groups
- Blue/Green deployments

---

## 2. prevent_destroy

Prevents accidental deletion of critical resources.

```hcl
resource "aws_db_instance" "prod" {
  lifecycle {
    prevent_destroy = true
  }
}
```

### Production Examples
- RDS databases
- KMS keys
- Backup S3 buckets
- Route53 hosted zones

---

## 3. ignore_changes

Tells Terraform to ignore changes to specific attributes.

### ECS Example

```hcl
resource "aws_ecs_service" "app" {
  desired_count = 2

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}
```

Useful when ECS Auto Scaling modifies the task count.

### ASG Example

```hcl
lifecycle {
  ignore_changes = [
    desired_capacity
  ]
}
```

### Ignore Tags

```hcl
lifecycle {
  ignore_changes = [
    tags
  ]
}
```

### Ignore Everything (Rare)

```hcl
lifecycle {
  ignore_changes = all
}
```

---

## 4. replace_triggered_by

Forces recreation when another resource changes.

```hcl
resource "aws_instance" "app" {
  lifecycle {
    replace_triggered_by = [
      aws_security_group.app
    ]
  }
}
```

### ECS Example

```hcl
resource "aws_ecs_service" "app" {
  lifecycle {
    replace_triggered_by = [
      aws_ecs_task_definition.app
    ]
  }
}
```

---

## Combined Example

```hcl
resource "aws_ecs_service" "app" {
  desired_count = 2

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      desired_count
    ]
  }
}
```

---

# Interview Notes

## Why use ignore_changes?
To prevent Terraform from reverting changes made externally by:
- ECS Auto Scaling
- AWS-managed updates
- Manual operator actions

## Real Project Usage
- `prevent_destroy` → Production RDS
- `ignore_changes` → ECS desired count
- `create_before_destroy` → Zero-downtime deployments
- `replace_triggered_by` → Task definition updates

---

# Summary

| Argument | Purpose | Example |
|-----------|----------|----------|
| create_before_destroy | Avoid downtime | ECS, ALB |
| prevent_destroy | Protect resources | RDS, KMS |
| ignore_changes | Ignore external modifications | ECS Scaling |
| replace_triggered_by | Force recreation | Task Definition Changes |
