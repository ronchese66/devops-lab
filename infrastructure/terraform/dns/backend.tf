terraform {
  backend "s3" {
    bucket       = "ronchese-immich-terraform-state"
    key          = "dns/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}