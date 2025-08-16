variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "demo/helloworld"
}

variable "service_name" {
  description = "App Runner service name"
  type        = string
  default     = "helloworld"
}

variable "image_tag" {
  description = "Image tag to deploy"
  type        = string
  default     = "latest"
}