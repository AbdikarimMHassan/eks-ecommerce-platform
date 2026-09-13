data "aws_secretsmanager_random_password" "postgres" {
  password_length     = 32
  exclude_punctuation = true
}

data "aws_secretsmanager_random_password" "redis" {
  password_length     = 32
  exclude_punctuation = true
}

data "aws_secretsmanager_random_password" "jwt" {
  password_length     = 64
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret" "postgres" {
  name = "${var.environment}/postgres/credentials"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    username          = "postgres"
    password          = data.aws_secretsmanager_random_password.postgres.random_password
    database          = "ecommerce"
    host              = "postgres-0.postgres.${var.namespace}.svc.cluster.local"
    port              = "5432"
    connection-string = "postgresql://postgres:${data.aws_secretsmanager_random_password.postgres.random_password}@postgres-0.postgres.${var.namespace}.svc.cluster.local:5432/ecommerce"
  })
}

resource "aws_secretsmanager_secret" "redis" {
  name = "${var.environment}/redis/credentials"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    password = data.aws_secretsmanager_random_password.redis.random_password
    host     = "redis-0.redis.${var.namespace}.svc.cluster.local"
    port     = "6379"
    url      = "redis://:${data.aws_secretsmanager_random_password.redis.random_password}@redis-0.redis.${var.namespace}.svc.cluster.local:6379"
  })
}

resource "aws_secretsmanager_secret" "jwt" {
  name = "${var.environment}/app/jwt-secret"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id = aws_secretsmanager_secret.jwt.id
  secret_string = jsonencode({
    secret = data.aws_secretsmanager_random_password.jwt.random_password
  })
}