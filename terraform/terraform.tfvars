# General
name   = "juned-cluster"
aws_tags = {
  Environment = "dev"
  Project     = "eks"
  Owner       = "juned"
  Terraform   = "true"
}

# EKS
authentication_mode                         = "API"
bootstrap_cluster_creator_admin_permissions = true
cluster_version                             = "1.31"
endpoint_private_access                     = true
endpoint_public_access                      = true
upgrade_support_type                        = "STANDARD"
node_group_name                             = "eks-infra-node"
desired_size                                = 1
max_size                                    = 1
min_size                                    = 1
instance_disk_size                          = 50
instance_types                              = ["t3.large"]
capacity_type                               = "SPOT"
eks_cluster_role_name                       = "eks-cluster-role"
eks_node_group_role_name                    = "eks-node-group-role"

# Pod Identity
cert_manager_namespace = "cert-manager"
external_dns_namespace = "external-dns"
external_secrets_namespace = "external-secrets"
karpenter_namespace = "karpenter"

# Route53
domain_name = "lab.juned.co.uk"

# VPC
vpc_cidr_block                 = "10.0.0.0/16"
publicsubnet1_cidr_block       = "10.0.1.0/24"
publicsubnet2_cidr_block       = "10.0.2.0/24"
privatesubnet1_cidr_block      = "10.0.3.0/24"
privatesubnet2_cidr_block      = "10.0.4.0/24"
enable_dns_support             = true
enable_dns_hostnames           = true
subnet_map_public_ip_on_launch = true
availability_zone_1            = "eu-west-2a"
availability_zone_2            = "eu-west-2b"
route_cidr_block               = "0.0.0.0/0"