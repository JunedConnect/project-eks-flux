resource "aws_iam_role" "cert-manager-role" {
  name = "cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "cert-manager-policy" {
  name = "cert-manager-policy"
  role = aws_iam_role.cert-manager-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "route53:GetChange",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Action" : [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        "Action" : "route53:ListHostedZonesByName",
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role" "external-dns-role" {
  name = "external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]

    }]
  })
}

resource "aws_iam_role_policy" "external-dns-policy" {
  name = "external-dns-policy"
  role = aws_iam_role.external-dns-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "route53:ChangeResourceRecordSets",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
      },
      {
        "Action" : [
          "route53:ListTagsForResource",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role" "external-secrets-role" {
  name = "external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "external-secrets-policy" {
  name = "external-secrets-policy"
  role = aws_iam_role.external-secrets-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Effect" : "Allow",
        "Resource" : "*" # to be updated to the specific secret store
      }
    ]
  })
}

# data sources needed for the karpenter policy
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "karpenter-role" {
  name = "karpenter-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

# Custom Karpenter policy (policy from here: https://medium.com/@vajrapusri08/elevate-your-private-eks-cluster-autoscaling-with-karpenter-the-modern-autoscaler-df859fa07225)
resource "aws_iam_role_policy" "karpenter-policy" {
  name = "karpenter-policy"
  role = aws_iam_role.karpenter-role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowScopedEC2InstanceAccessActions",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}::image/*",
          "arn:aws:ec2:${data.aws_region.current.name}::snapshot/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:security-group/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:subnet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:capacity-reservation/*"
        ],
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
      },
      {
        "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
        "Effect": "Allow",
        "Resource": "arn:aws:ec2:${data.aws_region.current.name}:*:launch-template/*",
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedEC2InstanceActionsWithTags",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}:*:fleet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:volume/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:network-interface/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:launch-template/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:spot-instances-request/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:capacity-reservation/*"
        ],
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:RequestTag/eks:eks-cluster-name": "${var.cluster_name}"
          },
          "StringLike": {
            "aws:RequestTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedResourceCreationTagging",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}:*:fleet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:volume/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:network-interface/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:launch-template/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:spot-instances-request/*"
        ],
        "Action": "ec2:CreateTags",
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:RequestTag/eks:eks-cluster-name": "${var.cluster_name}",
            "ec2:CreateAction": [
              "RunInstances",
              "CreateFleet",
              "CreateLaunchTemplate"
            ]
          },
          "StringLike": {
            "aws:RequestTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedResourceTagging",
        "Effect": "Allow",
        "Resource": "arn:aws:ec2:${data.aws_region.current.name}:*:instance/*",
        "Action": "ec2:CreateTags",
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.sh/nodepool": "*"
          },
          "StringEqualsIfExists": {
            "aws:RequestTag/eks:eks-cluster-name": "${var.cluster_name}"
          },
          "ForAllValues:StringEquals": {
            "aws:TagKeys": [
              "eks:eks-cluster-name",
              "karpenter.sh/nodeclaim",
              "Name"
            ]
          }
        }
      },
      {
        "Sid": "AllowScopedDeletion",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:*:launch-template/*"
        ],
        "Action": [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowRegionalReadActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "ec2:DescribeCapacityReservations",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestedRegion": "${data.aws_region.current.name}"
          }
        }
      },
      {
        "Sid": "AllowSSMReadActions",
        "Effect": "Allow",
        "Resource": "arn:aws:ssm:${data.aws_region.current.name}::parameter/aws/service/*",
        "Action": "ssm:GetParameter"
      },
      {
        "Sid": "AllowPricingReadActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": "pricing:GetProducts"
      },
      {
        "Sid": "AllowInterruptionQueueActions",
        "Effect": "Allow",
        "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.cluster_name}",
        "Action": [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
      },
      {
        "Sid": "AllowPassingInstanceRole",
        "Effect": "Allow",
        "Resource": "${var.karpenter_node_role_arn}",
        "Action": "iam:PassRole",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": [
              "ec2.amazonaws.com",
              "ec2.amazonaws.com.cn"
            ]
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileCreationActions",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
        "Action": [
          "iam:CreateInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:RequestTag/eks:eks-cluster-name": "${var.cluster_name}",
            "aws:RequestTag/topology.kubernetes.io/region": "${data.aws_region.current.name}"
          },
          "StringLike": {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileTagActions",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
        "Action": [
          "iam:TagInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:ResourceTag/topology.kubernetes.io/region": "${data.aws_region.current.name}",
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:RequestTag/eks:eks-cluster-name": "${var.cluster_name}",
            "aws:RequestTag/topology.kubernetes.io/region": "${data.aws_region.current.name}"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileActions",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
        "Action": [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
            "aws:ResourceTag/topology.kubernetes.io/region": "${data.aws_region.current.name}"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowInstanceProfileReadActions",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
        "Action": "iam:GetInstanceProfile"
      },
      {
        "Sid": "AllowAPIServerEndpointDiscovery",
        "Effect": "Allow",
        "Resource": "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}",
        "Action": "eks:DescribeCluster"
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "cert-manager" {
  cluster_name    = var.cluster_name
  namespace       = var.cert_manager_namespace
  service_account = "cert-manager"
  role_arn        = aws_iam_role.cert-manager-role.arn
}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = var.cluster_name
  namespace       = var.external_dns_namespace
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns-role.arn
}

resource "aws_eks_pod_identity_association" "external-secrets" {
  cluster_name    = var.cluster_name
  namespace       = var.external_secrets_namespace
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external-secrets-role.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = var.karpenter_namespace
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter-role.arn
}