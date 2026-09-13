terraform {
  backend "s3" {
    bucket       = "ecom-eks-tfstate-779846800049"
    key          = "environments/prod/eks.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}