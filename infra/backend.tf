terraform {
  backend "s3" {
    bucket          = "cwm-tf-states"
    key             = "apprunner/helloworld/terraform.tfstate"
    region          = "us-east-1"
    use_lockfile    = true
  }
}
