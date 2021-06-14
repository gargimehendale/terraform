module "vpc"{
source = "./modules/vpc"
vpc_id = module.vpc.vpc_id
}
module "rds"{
source = "./modules/rds"
rds_sg_id = module.vpc.rds_sg_id
ec2_sg_id = module.vpc.ec2_sg_id
private_subnet_id = module.vpc.private_subnet_id
public_subnet_id = module.vpc.public_subnet_id
vpc_id = module.vpc.vpc_id

}
