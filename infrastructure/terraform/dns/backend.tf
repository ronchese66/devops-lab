terraform {
  backend "s3" {
    bucket       = "immich-ronchese-s3-state"
    key          = "dns/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}