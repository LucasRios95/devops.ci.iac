resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]



  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]


  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "tf-role" {
  name = "tf-role"
  assume_role_policy = jsonencode({
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::751647213111:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ]
          },
          StringLike : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:LucasRios95/devops.ci.iac:ref:refs/heads/main",
              "repo:LucasRios95/devops.ci.iac:ref:refs/heads/main"
            ]
          }
        }
    }]
  })

  inline_policy {
    name = "tf-app-permission"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "Statement1",
          Action   = "ecr:*",
          Effect   = "Allow",
          Resource = "*"
        },

        {
          Sid      = "Statement2",
          Action   = "iam:*",
          Effect   = "Allow",
          Resource = "*"
        },

      ]
    })
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({

    Version : "2012-10-17",
    Statement : [
      {

        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::751647213111:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ]
          },
          StringLike : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:LucasRios95/devops.ci.api:ref:refs/heads/main",
              "repo:LucasRios95/devops.ci.api:ref:refs/heads/main"
            ]
          }
        }
    }]
  })

  inline_policy {
    name = "ecr-app-permission"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "Statement1",
          Action   = "apprunner:*",
          Effect   = "Allow",
          Resource = "*"
        },

        {
          Sid = "Statement2",
          Action = [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole"
          ],
          Effect   = "Allow",
          Resource = "*"
        },

        {
          Sid = "Statement3"
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage",
            "ecr:GetAuthorizationToken"
          ]
          Effect   = "Allow"
          Resource = "*"
        },

        {
          Sid      = "Statement4"
          Action   = "wafv2:GetWebACLForResource"
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    IAC = "True"
  }
}