variable "name" {
  description = "Resource Name"
  type        = string
}

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  type        = string
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant bootstrap cluster creator admin permissions"
  type        = bool
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster API server is reachable from private endpoints"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API server is reachable from public endpoints"
  type        = bool
}

variable "upgrade_support_type" {
  description = "The support type for the upgrade policy."
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
}

variable "instance_disk_size" {
  description = "Disk size for instances"
  type        = number
}

variable "instance_types" {
  description = "List of instance types to be used within the cluster"
  type        = list(string)
}

variable "capacity_type" {
  description = "Type of capacity for the EKS node group"
  type        = string
}

variable "eks_cluster_role_name" {
  description = "Name of the EKS cluster role"
  type        = string
}

variable "eks_node_group_role_name" {
  description = "Name of the EKS node group role"
  type        = string
}

variable "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Public subnet 1 ID"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Public subnet 2 ID"
  type        = string
}

variable "private_subnet_1_id" {
  description = "Private subnet 1 ID"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Private subnet 2 ID"
  type        = string
}