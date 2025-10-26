output "cert_manager_role_arn" {
  value = aws_iam_role.cert-manager-role.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external-dns-role.arn
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external-secrets-role.arn
}

output "karpenter_role_arn" {
  value = aws_iam_role.karpenter-role.arn
}