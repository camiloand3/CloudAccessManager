
terraform {
  backend "s3" {
    bucket = "tfstate-533613205608-us-east-1"
    key = "iam-roles/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}