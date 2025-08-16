terraform {
  backend "s3" {
    bucket          = "cwm-tf-states"
    key             = "apprunner/helloworld/terraform.tfstate"
    region          = "us-east-1"

    # Latest: enable S3-native locking (DynamoDB locking is deprecated)
    use_lockfile    = true
  }
}
