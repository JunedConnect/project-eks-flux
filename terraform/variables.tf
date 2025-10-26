#General

variable "name" {
  description = "Resource Name"
  type        = string
  default     = "test"
}


variable "aws_tags" {
  description = "Tags for Resources"
  type        = map(string)
  default = {
    Environment = "dev",
    Project     = "eks",
    Owner       = "juned",
    Terraform   = "true"
  }
}


#eks

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  type        = string
  default     = "API"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant bootstrap cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster API server is reachable from private endpoints"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API server is reachable from public endpoints"
  type        = bool
  default     = true
}

variable "upgrade_support_type" {
  description = "The support type for the upgrade policy."
  type        = string
  default     = "STANDARD"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "eks-node-group"
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "instance_disk_size" {
  description = "Disk size for instances"
  type        = number
  default     = 50
}

variable "instance_types" {
  description = "List of instance types to be used within the cluster"
  type        = list(string)
  default     = ["t3.large"]
}

variable "capacity_type" {
  description = "Type of capacity for the EKS node group"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_cluster_role_name" {
  description = "Name of the EKS cluster role"
  type        = string
  default     = "eks-cluster-role"
}

variable "eks_node_group_role_name" {
  description = "Name of the EKS node group role"
  type        = string
  default     = "eks-node-group-role"
}




#podidentity

variable "cert_manager_namespace" {
  description = "The namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "external_dns_namespace" {
  description = "The namespace for external-dns"
  type        = string
  default     = "external-dns"
}

variable "external_secrets_namespace" {
  description = "The namespace for external-secrets"
  type        = string
  default     = "external-secrets"
}

variable "karpenter_namespace" {
  description = "The namespace for karpenter"
  type        = string
  default     = "karpenter"
}


#route53

variable "domain_name" {
  description = "The domain name for the Route53 hosted zone"
  type        = string
  default     = "lab.juned.co.uk"
}


#vpc

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "publicsubnet1_cidr_block" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "publicsubnet2_cidr_block" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "privatesubnet1_cidr_block" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "privatesubnet2_cidr_block" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "subnet_map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for subnets"
  type        = bool
  default     = true
}

variable "availability_zone_1" {
  description = "Availability zone 1"
  type        = string
  default     = "eu-west-2a"
}

variable "availability_zone_2" {
  description = "Availability zone 2"
  type        = string
  default     = "eu-west-2b"
}

variable "route_cidr_block" {
  description = "CIDR block for the route"
  type        = string
  default     = "0.0.0.0/0"
}