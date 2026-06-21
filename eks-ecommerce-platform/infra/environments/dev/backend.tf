terraform {
  backend "s3" {
    bucket       = "ecom-eks-tfstate"
    key          = "environments/dev/eks.tfstate" 
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true 
  }
}