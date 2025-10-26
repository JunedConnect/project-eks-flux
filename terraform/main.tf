module "eks" {
  source = "./modules/eks"

  public_subnet_1_id  = module.vpc.public_subnet_1_id
  public_subnet_2_id  = module.vpc.public_subnet_2_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id

  name                                        = var.name
  authentication_mode                         = var.authentication_mode
  bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  cluster_version                             = var.cluster_version
  endpoint_private_access                     = var.endpoint_private_access
  endpoint_public_access                      = var.endpoint_public_access
  upgrade_support_type                        = var.upgrade_support_type

  node_group_name    = var.node_group_name
  desired_size       = var.desired_size
  max_size           = var.max_size
  min_size           = var.min_size
  instance_disk_size = var.instance_disk_size
  instance_types     = var.instance_types
  capacity_type      = var.capacity_type

  eks_cluster_role_name    = var.eks_cluster_role_name
  eks_node_group_role_name = var.eks_node_group_role_name

}

module "karpenter" {
  source = "./modules/karpenter"

  cluster_name = module.eks.eks_cluster_name
}


module "podidentity" {
  source = "./modules/podidentity"

  cluster_name    = module.eks.eks_cluster_name
  route53_zone_id = module.route53.route53_zone_id

  cert_manager_namespace = var.cert_manager_namespace
  external_dns_namespace = var.external_dns_namespace
  external_secrets_namespace = var.external_secrets_namespace
  karpenter_namespace = var.karpenter_namespace

  karpenter_node_role_arn = module.karpenter.karpenter_node_role_arn
}

module "route53" {
  source = "./modules/route53"

  domain_name = var.domain_name

}

module "vpc" {
  source = "./modules/vpc"

  name                           = var.name
  vpc_cidr_block                 = var.vpc_cidr_block
  publicsubnet1_cidr_block       = var.publicsubnet1_cidr_block
  publicsubnet2_cidr_block       = var.publicsubnet2_cidr_block
  privatesubnet1_cidr_block      = var.privatesubnet1_cidr_block
  privatesubnet2_cidr_block      = var.privatesubnet2_cidr_block
  enable_dns_support             = var.enable_dns_support
  enable_dns_hostnames           = var.enable_dns_hostnames
  subnet_map_public_ip_on_launch = var.subnet_map_public_ip_on_launch
  availability_zone_1            = var.availability_zone_1
  availability_zone_2            = var.availability_zone_2
  route_cidr_block               = var.route_cidr_block

}