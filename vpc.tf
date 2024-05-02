module "cs_vpc" {
  source = "git@github.com:draios/cs-terraform-modules.git//terraform-cs-aws-vpc"
  #source = "/Users/patrick.easters/git/draios/cs-terraform-modules/terraform-cs-aws-vpc"
  aws_region   = var.aws_region
  nat_instance = true
}