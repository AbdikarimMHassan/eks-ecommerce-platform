# Using random_password resources (stored in state) rather than the
# aws_secretsmanager_random_password data source - that data source is
# re-evaluated on every plan/apply and generates a genuinely new value each
# time, which silently drifts the password out from under services (and,
# for postgres/redis, out from under an already-initialized database that
# only ever applies its password once, on first startup).
resource "random_password" "postgres" {
  length  = 32
  special = false
}

resource "random_password" "redis" {
  length  = 32
  special = false
}

resource "random_password" "jwt" {
  length  = 64
  special = false
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
    password          = random_password.postgres.result
    database          = "ecommerce"
    host              = "postgres-0.postgres.${var.namespace}.svc.cluster.local"
    port              = "5432"
    connection-string = "postgresql://postgres:${random_password.postgres.result}@postgres-0.postgres.${var.namespace}.svc.cluster.local:5432/ecommerce?sslmode=disable"
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
    password = random_password.redis.result
    host     = "redis-0.redis.${var.namespace}.svc.cluster.local"
    port     = "6379"
    url      = "redis://:${random_password.redis.result}@redis-0.redis.${var.namespace}.svc.cluster.local:6379"
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
    secret = random_password.jwt.result
  })
}