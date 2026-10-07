# AWS IAM roles with Terraform (no Okta yet)

Creates four IAM roles with their permission policies, plus three S3 buckets
the policies point at. No required inputs: run it and it works.

| Role | Permissions |
|---|---|
| `Okta-Developer` | Describe EC2, start/stop only `Environment=Dev` instances, read S3 |
| `Okta-DataAnalyst` | Read analytics bucket, Athena queries, Glue catalog read |
| `Okta-MLEngineer` | SageMaker jobs/endpoints/notebooks, ML bucket, ECR pull, logs |
| `Okta-Auditor` | `SecurityAudit` + `ViewOnlyAccess` (AWS-managed) |

## Structure

```
aws-iam-roles-terraform/
├── README.md
├── .gitignore
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf               # role catalogue
├── policies.tf             # permissions for each role
├── buckets.tf              # lab S3 buckets
├── main.tf                 # creates every role from the catalogue
├── outputs.tf
├── terraform.tfvars.example
└── modules/
    └── iam-role/           # role + trust policy + permissions
```

## Run it

```bash
aws sts get-caller-identity     # confirm you are in the right account
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Try a role

Use the `console_switch_role_urls` or `cli_assume_role_commands` outputs.
The trust policy allows the account, but your own user also needs permission
to call `sts:AssumeRole` (admin users already have it).

## Cleanup

```bash
terraform destroy
```

## Later: add Okta

Only the trust policy changes (principal becomes the SAML provider and the
action becomes `sts:AssumeRoleWithSAML`). Permission policies stay as they are.
