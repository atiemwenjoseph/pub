############## Module File #############\

locals {
  cwd           = reverse(split("/", path.cwd))
  instance_type = local.cwd[1]
  location      = local.cwd[2]
  environment   = local.cwd[3]
  vpc_cidr      = "10.123.0.0/16"
}

############## Networking ######################

module "networking" {
  source            = "./Network"
  vpc_cidr          = "10.123.0.0/16"
  access_ip         = "0.0.0.0/0"
  public_sn_count   = 2
  private_sn_count  = 2
  db_subnet_group   = true
  availabilityzone  = "eu-west-2"
  azs               = 2
}

################ Compute ####################

module "compute" {
  source = "./Compute"
  frontend_app_sg         = module.networking.frontend_app_sg
  backend_app_sg          = module.networking.backend_app_sg
  bastion_sg              = module.networking.bastion_sg
  public_subnets          = module.networking.public_subnets
  private_subnets         = module.networking.private_subnets
  bastion_instance_count  = 1
  instance_type           = local.instance_type
  key_name                = "Three-Tier-Terraform"
  lb_tg_name              = module.loadbalancing.lb_tg_name
  lb_tg                   = module.loadbalancing.lb_tg

}

module "database" {
  source               = "./Database"
  db_storage           = 10
  db_engine_version    = "5.7.22"
  db_instance_class    = "db.t2.micro"
  db_name              = "Data-Bank"
  dbuser               = "admin_name"
  dbpassword           = "12345"
  db_identifier        = "three-tier-db"
  skip_db_snapshot     = true
  rds_sg               = module.networking.rds_sg
  db_subnet_group_name = module.networking.db_subnet_group_name[0]
}

module "loadbalancing" {
  source                  = "./Loadbalancer"
  lb_sg                   = module.networking.lb_sg
  public_subnets          = module.networking.public_subnets
  tg_port                 = 80
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  app_asg                 = module.compute.app_asg
  listener_port           = 80
  listener_protocol       = "HTTP"
  azs                     = 2
}


