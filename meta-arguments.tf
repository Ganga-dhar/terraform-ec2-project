## 🎯 Key Concepts

### Meta-Arguments Overview

Meta-arguments are special arguments that can be used with **any resource type** to change the behavior of resources:

1. **count** - Create multiple resource instances based on a number
2. **for_each** - Create multiple resource instances based on a map or set
3. **depends_on** - Explicit resource dependencies
4. **lifecycle** - Customize resource lifecycle behavior
5. **provider** - Select a non-default provider configuration
6. **provisioner** - Execute scripts on resource creation/destruction (not recommended)


🔹 1. count :

Create multiple identical resources with minimal code.
Ex:
resource "aws_instance" "web" {
  count = 3
}

🔹 2. for_each:

Create resources using unique keys from a map or set of strings.
resource "aws_instance" "server" {
  for_each = {
    web = "t3.micro"
    app = "t3.small"
  }
}

🔹 3. depends_on:

Define explicit dependencies when Terraform cannot infer them automatically.Ensures resources are created in the exact correct order.

depends_on = [
  aws_security_group.web
]

🔹 4. lifecycle:

 Control exactly how Terraform handles resource changes. Helps to reduce downtime during updates and protects your most critical infrastructure (like production databases) from accidental destruction
resource "aws_s3_bucket" "example" {
 bucket = "my-bucket"
 lifecycle {
  prevent_destroy    = true # Prevent accidental deletion
  create_before_destroy = true # Create new before destroying old
  ignore_changes    = [tags] # Ignore changes to tags
 }
}

🔹 5. provider:

Point a specific resource block to a non-default provider configuration. A must-have for managing multi-region or multi-account deployments within the same state file.

resource "aws_s3_bucket" "example" {
 provider = aws.west # Use alternate provider
 bucket  = "my-bucket"
}

🔹 6. providers:

Pass specific provider configurations down into child modules. Enables you to keep your custom modules highly reusable across completely different environments and regions.

module "network" {
  source = "./network"
  providers = {
    aws = aws.us_west
  }
}
