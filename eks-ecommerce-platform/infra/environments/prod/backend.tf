terraform {
  backend "s3" {
    bucket       = "ecom-eks-tfstate"
    key          = "environments/prod/eks.tfstate" 
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true 
  }
}