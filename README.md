# Secure AWS DevSecOps Pipeline

This project is a secure CI pipeline for AWS infrastructure built with Terraform and GitHub Actions.

The goal was to practice building AWS infrastructure with security checks built directly into the development process. Whenever code is pushed to GitHub, the pipeline validates the Terraform configuration and uses Checkov to scan it for security issues.

AWS authentication is handled through GitHub OIDC, so the pipeline does not need long-lived AWS access keys stored in GitHub.

## How It Works

```text
Developer pushes code
        |
        v
GitHub Repository
        |
        v
GitHub Actions
        |
        +-- Terraform Format Check
        +-- Terraform Validate
        +-- Checkov Security Scan
        |
        v
GitHub OIDC
        |
        v
AWS IAM Role
        |
        v
AWS
```

The workflow runs automatically on pushes and pull requests to the `main` branch.

Before the Terraform configuration passes CI, the pipeline:

1. Checks out the repository
2. Sets up Terraform
3. Authenticates to AWS through OIDC
4. Verifies the AWS identity
5. Runs `terraform init`
6. Checks Terraform formatting
7. Runs `terraform validate`
8. Scans the infrastructure with Checkov

If one of the security checks enforced by the pipeline fails, the workflow fails too.

## Security Features

The project currently includes:

- S3 Block Public Access
- S3 encryption at rest
- KMS-backed encryption
- S3 versioning
- Lifecycle rules
- Cleanup of incomplete multipart uploads
- S3 access logging
- Checkov security scanning
- GitHub OIDC authentication
- No hard-coded AWS credentials

## GitHub OIDC Authentication

Instead of putting an AWS access key and secret key in GitHub, this project uses OpenID Connect (OIDC).

GitHub Actions receives an OIDC token and uses it to assume an AWS IAM role through AWS STS.

```text
GitHub Actions
      |
      | OIDC token
      v
AWS STS
      |
      v
AWS IAM Role
      |
      v
Temporary Credentials
```

This keeps long-lived AWS credentials out of the CI pipeline.

## Checkov Security Scanning

Checkov scans the Terraform configuration during every CI run.

It checks the infrastructure for issues such as:

- Public S3 access
- Missing encryption
- Missing versioning
- Missing lifecycle controls
- Hard-coded AWS credentials
- Other insecure Terraform configurations

Current CI result:

```text
Passed checks: 13
Failed checks: 0
```

The repository also contains intentionally insecure Terraform examples under:

```text
terraform/insecure_examples/
```

These are kept separate from the main infrastructure and excluded from the normal CI scan. They can be used to test how the security scanner reacts to insecure infrastructure.

## Checkov Exceptions

A few Checkov policies are intentionally excluded from the current pipeline, including controls that would require additional AWS infrastructure or ongoing cost.

The exceptions are documented in the workflow instead of simply ignoring the findings.

Examples include:

- Cross-region S3 replication
- S3 event notifications
- Additional logging requirements outside the current project scope

These are possible improvements for a future version of the project.

## Project Structure

```text
secure-aws-devsecops-pipeline/
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── terraform/
│   ├── insecure_examples/
│   │   └── main.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── .gitignore
└── README.md
```

Terraform state files and the local `.terraform` directory are excluded from Git.

## Tools Used

- AWS
- Terraform
- GitHub Actions
- GitHub OIDC
- AWS IAM and STS
- Amazon S3
- AWS KMS
- Checkov

## Future Improvements

Some things I would like to add in a future version:

- AWS Config monitoring
- Cross-region replication
- Event-driven security monitoring
- Remote Terraform state
- More AWS infrastructure
- Automated deployment after security checks pass

For now, the project focuses on building a secure Terraform CI workflow while keeping the AWS environment small and inexpensive.