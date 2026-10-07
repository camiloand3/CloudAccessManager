output "role_arns" {
  description = "ARN of each role."
  value       = { for name, r in module.role : name => r.arn }
}

output "console_switch_role_urls" {
  description = "Open while signed in to the console to switch into each role."
  value = {
    for name, r in module.role :
    name => "https://signin.aws.amazon.com/switchrole?roleName=${r.name}&account=${local.account_id}"
  }
}

output "cli_assume_role_commands" {
  description = "Run one to get temporary credentials for a role."
  value = {
    for name, r in module.role :
    name => "aws sts assume-role --role-arn ${r.arn} --role-session-name test"
  }
}

output "lab_buckets" {
  description = "Buckets created for the lab."
  value       = { for k, b in aws_s3_bucket.lab : k => b.bucket }
}
