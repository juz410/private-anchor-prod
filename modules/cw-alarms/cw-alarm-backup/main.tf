locals {
  vault_configs = {
    for key, vault in var.vaults :
    key => {
      vault_name = vault.vault_name
      label      = try(vault.display_name, vault.vault_name)
    }
  }

  event_bus_name = coalesce(var.event_bus_name, "default")

  success_rules = {
    for key, vault in local.vault_configs :
    key => {
      name        = substr("${var.resource_name_prefix}-${vault.label}-backup-success", 0, 64)
      description = "Backup job completed for vault ${vault.vault_name}"
      event_pattern = jsonencode({
        "source"      : ["aws.backup"],
        "detail-type" : ["Backup Job State Change"],
        "detail"      : {
          "backupVaultName" : [vault.vault_name],
          "state"           : ["COMPLETED"]
        }
      })
    }
  }

  failed_rules = {
    for key, vault in local.vault_configs :
    key => {
      name        = substr("${var.resource_name_prefix}-${vault.label}-backup-failed", 0, 64)
      description = "Backup job failed for vault ${vault.vault_name}"
      event_pattern = jsonencode({
        "source"      : ["aws.backup"],
        "detail-type" : ["Backup Job State Change"],
        "detail"      : {
          "backupVaultName" : [vault.vault_name],
          "state"           : ["FAILED"]
        }
      })
    }
  }

  expired_rules = {
    for key, vault in local.vault_configs :
    key => {
      name        = substr("${var.resource_name_prefix}-${vault.label}-backup-expired", 0, 64)
      description = "Backup job expired for vault ${vault.vault_name}"
      event_pattern = jsonencode({
        "source"      : ["aws.backup"],
        "detail-type" : ["Backup Job State Change"],
        "detail"      : {
          "backupVaultName" : [vault.vault_name],
          "state"           : ["EXPIRED"]
        }
      })
    }
  }
}

resource "aws_cloudwatch_event_rule" "success" {
  for_each            = local.success_rules
  name                = each.value.name
  description         = each.value.description
  event_pattern       = each.value.event_pattern
  event_bus_name      = local.event_bus_name
  tags                = var.tags
}

resource "aws_cloudwatch_event_rule" "failed" {
  for_each            = local.failed_rules
  name                = each.value.name
  description         = each.value.description
  event_pattern       = each.value.event_pattern
  event_bus_name      = local.event_bus_name
  tags                = var.tags
}

resource "aws_cloudwatch_event_rule" "expired" {
  for_each            = local.expired_rules
  name                = each.value.name
  description         = each.value.description
  event_pattern       = each.value.event_pattern
  event_bus_name      = local.event_bus_name
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "success" {
  for_each = aws_cloudwatch_event_rule.success

  rule          = each.value.name
  target_id     = "lambda-backup-publisher"
  arn           = var.lambda_function_arn
  event_bus_name = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "failed" {
  for_each = aws_cloudwatch_event_rule.failed

  rule          = each.value.name
  target_id     = "lambda-backup-publisher"
  arn           = var.lambda_function_arn
  event_bus_name = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "expired" {
  for_each = aws_cloudwatch_event_rule.expired

  rule          = each.value.name
  target_id     = "lambda-backup-publisher"
  arn           = var.lambda_function_arn
  event_bus_name = local.event_bus_name
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = merge(
    { for k, v in aws_cloudwatch_event_rule.success : "success-${k}" => v },
    { for k, v in aws_cloudwatch_event_rule.failed  : "failed-${k}"  => v },
    { for k, v in aws_cloudwatch_event_rule.expired : "expired-${k}" => v },
  )

  statement_id  = "AllowExecutionFromEvents-${each.value.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}

# locals {
#   norm_resources = {
#     for k, r in var.resources :
#     k => merge(
#       r,
#       { type = upper(try(r.type, "")) } # normalise; "" if not set
#     )
#   }

#   # ---------- SUCCESS (COMPLETED) ----------
#   success_defs = [
#     for key, r in local.norm_resources : {
#       key           = "${key}_success"
#       rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-success", 0, 64)
#       description   = "AWS Backup job COMPLETED for ${r.name}"
#       state         = "COMPLETED"
#       topic_arn     = var.sns_topics.success
#       resource_arn  = r.arn
#       resource_type = r.type
#     }
#   ]
#   success_map = { for d in local.success_defs : d.key => d }

#   # ---------- FAILED ----------
#   failed_defs = [
#     for key, r in local.norm_resources : {
#       key           = "${key}_failed"
#       rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-failed", 0, 64)
#       description   = "AWS Backup job FAILED for ${r.name}"
#       state         = "FAILED"
#       topic_arn     = var.sns_topics.failed
#       resource_arn  = r.arn
#       resource_type = r.type
#     }
#   ]
#   failed_map = { for d in local.failed_defs : d.key => d }

#   # ---------- EXPIRED ----------
#   expired_defs = [
#     for key, r in local.norm_resources : {
#       key           = "${key}_expired"
#       rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-expired", 0, 64)
#       description   = "AWS Backup job EXPIRED for ${r.name}"
#       state         = "EXPIRED"
#       topic_arn     = var.sns_topics.expired
#       resource_arn  = r.arn
#       resource_type = r.type
#     }
#   ]
#   expired_map = { for d in local.expired_defs : d.key => d }
# }

# # =============== SUCCESS ===================

# resource "aws_cloudwatch_event_rule" "backup_success" {
#   for_each = local.success_map

#   name        = each.value.rule_name
#   description = each.value.description

#   event_pattern = jsonencode({
#     "source"      : ["aws.backup"],
#     "detail-type" : ["Backup Job State Change"],
#     "detail" : {
#       "state"       : [each.value.state],
#       "resourceArn" : [each.value.resource_arn]
#       # we could also AND resourceType = each.value.resource_type if you really want
#     }
#   })

#   tags = var.tags
# }

# resource "aws_cloudwatch_event_target" "backup_success_sns" {
#   for_each = aws_cloudwatch_event_rule.backup_success

#   rule      = each.value.name
#   target_id = "sns"
#   arn       = local.success_map[each.key].topic_arn
# }

# # =============== FAILED ====================

# resource "aws_cloudwatch_event_rule" "backup_failed" {
#   for_each = local.failed_map

#   name        = each.value.rule_name
#   description = each.value.description

#   event_pattern = jsonencode({
#     "source"      : ["aws.backup"],
#     "detail-type" : ["Backup Job State Change"],
#     "detail" : {
#       "state"       : [each.value.state],
#       "resourceArn" : [each.value.resource_arn]
#     }
#   })

#   tags = var.tags
# }

# resource "aws_cloudwatch_event_target" "backup_failed_sns" {
#   for_each = aws_cloudwatch_event_rule.backup_failed

#   rule      = each.value.name
#   target_id = "sns"
#   arn       = local.failed_map[each.key].topic_arn
# }

# # =============== EXPIRED ====================

# resource "aws_cloudwatch_event_rule" "backup_expired" {
#   for_each = local.expired_map

#   name        = each.value.rule_name
#   description = each.value.description

#   event_pattern = jsonencode({
#     "source"      : ["aws.backup"],
#     "detail-type" : ["Backup Job State Change"],
#     "detail" : {
#       "state"       : [each.value.state],
#       "resourceArn" : [each.value.resource_arn]
#     }
#   })

#   tags = var.tags
# }

# resource "aws_cloudwatch_event_target" "backup_expired_sns" {
#   for_each = aws_cloudwatch_event_rule.backup_expired

#   rule      = each.value.name
#   target_id = "sns"
#   arn       = local.expired_map[each.key].topic_arn
# }


# #anchor extra alarm

