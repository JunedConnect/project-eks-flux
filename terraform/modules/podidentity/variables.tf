variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cert_manager_namespace" {
  description = "The namespace for cert-manager"
  type        = string
}

variable "external_dns_namespace" {
  description = "The namespace for external-dns"
  type        = string
}

variable "external_secrets_namespace" {
  description = "The namespace for external-secrets"
  type        = string
}

variable "karpenter_namespace" {
  description = "The namespace for karpenter"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  type        = string
}

