# Create the Route53 Zone for your 9 microservices
resource "aws_route53_zone" "primary" {
  name = var.domain_name # e.g., "prod.my-ecommerce-store.com"
  tags = {
    name        = "${var.environment}-route53-zone"
    Environment = var.environment
    
  }
}