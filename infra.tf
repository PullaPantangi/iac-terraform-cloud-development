module "cloud-compute-module" {
  source  = "app.terraform.io/Pulla-dev-test/cloud-compute-module/terraform"
  version = "1.0.0"
  vpc_cidr              = "10.1.0.0/16"
  vpc_name              = "dev-platinum-vpc"
  platinum-aws-igw-name = "dev-platinum-igw"
  pub_subnet_cidr       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  az                    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  pub_subnet_name       = "dev-platinum-pub-subnet"
  pvt_subent_cidr       = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  pvt_subnet_name       = "dev-platinum-pvt-subnet"
  igw_route             = "0.0.0.0/0"
  pub_RT_name           = "dev-platinum-pub-RT"
  pvt_RT_name           = "dev-platinum-pvt-RT"
}

module "cloud-sg-module" {
  source  = "app.terraform.io/Pulla-dev-test/cloud-sg-module/terraform"
  version = "1.0.0"
  vpc_id    = module.cloud-compute-module.vpc_id
  ports_in  = [80, 443, 22]
  igw_route = module.cloud-compute-module.igw_route
}

module "cloud-ec2-module" {
  source  = "app.terraform.io/Pulla-dev-test/cloud-ec2-module/terraform"
  version = "1.0.0"
  pub_subnet_cidr = module.cloud-compute-module.pub_subnet_cidr
  ami = {
    us-east-1 = "ami-0150ccaf51ab55a51"
  }
  instance_type = "t2.micro"
  key_name      = "test"
  region        = "us-east-1"
  sg_id         = module.cloud-sg-module.sg_id
  az            = module.cloud-compute-module.a_zone
  comman_tags   = module.cloud-compute-module.local_tags
  Env           = "dev"

}
module "cloud-alb-module" {
  source  = "app.terraform.io/Pulla-dev-test/cloud-alb-module/terraform"
  version = "1.0.0"
  alb_name     = "dev-ui-alb"
  sg_id        = module.cloud-sg-module.sg_id
  sub_id       = module.cloud-compute-module.pub_sub
  vpc_id       = module.cloud-compute-module.vpc_id
  instance_id  = module.cloud-ec2-module.instance_list
  pub_instance = module.cloud-ec2-module.instance_list
}