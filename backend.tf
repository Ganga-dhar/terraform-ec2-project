terraform {
  backend "s3" {
    bucket       = "terraform-state-demo1111"
    key          = "terraform/terraform.state"
    region       = "us-east-1"
    use_lockfile = true
  }
}
