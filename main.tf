module "vpc"{
source = "./modules/vpc"
vpc_id = module.vpc.vpc_id
}
module "rds"{
source = "./modules/rds"
rds_sg_id = module.vpc.rds_sg_id
ec2_sg_id = module.vpc.ec2_sg_id
private_subnet_id = module.vpc.private_subnet_id
}
module "ec2"{
source = "./modules/ec2"
public_subnet_id = module.vpc.public_subnet_id
ec2_sg_id = module.vpc.ec2_sg_id
}
