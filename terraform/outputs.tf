output "cert_manager_role_arn" {
  description = "ARN of the cert-manager IAM role"
  value       = module.podidentity.cert_manager_role_arn
}

output "external_dns_role_arn" {
  description = "ARN of the external-dns IAM role"
  value       = module.podidentity.external_dns_role_arn
}

output "external_secrets_role_arn" {
  description = "ARN of the external-secrets IAM role"
  value       = module.podidentity.external_secrets_role_arn
}

output "karpenter_role_arn" {
  description = "ARN of the karpenter IAM role"
  value       = module.podidentity.karpenter_role_arn
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = module.karpenter.karpenter_node_role_arn
}
