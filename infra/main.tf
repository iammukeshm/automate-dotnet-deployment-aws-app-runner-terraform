# ---------------------------
# IAM Role for App Runner
# ---------------------------
data "aws_iam_policy_document" "apprunner_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com", "tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apprunner_ecr_access" {
  name               = "${var.service_name}-ecr-access"
  assume_role_policy = data.aws_iam_policy_document.apprunner_trust.json
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# ---------------------------
# Auto Scaling Configuration
# ---------------------------
resource "aws_apprunner_auto_scaling_configuration_version" "basic" {
  auto_scaling_configuration_name = "${var.service_name}-asc"
  max_concurrency                 = 80
  min_size                        = 1
  max_size                        = 5
}

# ---------------------------
# App Runner Service
# ---------------------------
data "aws_caller_identity" "me" {}
data "aws_region" "cur" {}

locals {
  image = "${data.aws_caller_identity.me.account_id}.dkr.ecr.${data.aws_region.cur.id}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
}


resource "aws_apprunner_service" "api" {
  service_name                   = var.service_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.basic.arn

  source_configuration {
    image_repository {
      image_repository_type = "ECR"
      image_identifier      = local.image
      image_configuration {
        port = "8080"
      }
    }

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access.arn
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu    = "1024"  # 1 vCPU
    memory = "2048"  # 2 GB
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 3
  }
}

output "apprunner_service_url" {
  value = aws_apprunner_service.api.service_url
}