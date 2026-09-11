locals {
  services = toset([
    "api-gateway",
    "dashboard-api",
    "inventory-service",
    "notification-service",
    "order-service",
    "payment-service",
    "scheduler",
    "shipping-service",
    "worker"
  ])
}

resource "aws_ecr_repository" "services" {
  for_each = local.services

  name                 = "${var.environment}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Service     = each.value
  }
}

resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}