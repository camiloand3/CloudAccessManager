module "role" {
  source   = "./modules/iam-role"
  for_each = local.roles

  name                   = each.key
  description            = each.value.description
  trusted_principal_arns = local.trusted_principal_arns
  require_mfa            = var.require_mfa
  managed_policy_arns    = each.value.managed_policy_arns
  create_inline_policy   = each.value.create_inline_policy
  inline_policy_json     = each.value.inline_policy_json
  max_session_duration   = var.max_session_duration
  tags                   = local.common_tags
}