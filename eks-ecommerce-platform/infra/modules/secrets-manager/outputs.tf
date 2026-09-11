output "postgres_secret_arn" {
  description = "ARN of postgres secret"
  value       = aws_secretsmanager_secret.postgres.arn
}

output "redis_secret_arn" {
  description = "ARN of redis secret"
  value       = aws_secretsmanager_secret.redis.arn
}

output "jwt_secret_arn" {
  description = "ARN of JWT secret"
  value       = aws_secretsmanager_secret.jwt.arn
}