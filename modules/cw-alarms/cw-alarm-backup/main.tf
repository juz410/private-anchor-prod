locals {
  norm_resources = {
    for k, r in var.resources :
    k => merge(
      r,
      { type = upper(try(r.type, "")) } # normalise; "" if not set
    )
  }

  # ---------- SUCCESS (COMPLETED) ----------
  success_defs = [
    for key, r in local.norm_resources : {
      key           = "${key}_success"
      rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-success", 0, 64)
      description   = "AWS Backup job COMPLETED for ${r.name}"
      state         = "COMPLETED"
      topic_arn     = var.sns_topics.success
      resource_arn  = r.arn
      resource_type = r.type
    }
  ]
  success_map = { for d in local.success_defs : d.key => d }

  # ---------- FAILED ----------
  failed_defs = [
    for key, r in local.norm_resources : {
      key           = "${key}_failed"
      rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-failed", 0, 64)
      description   = "AWS Backup job FAILED for ${r.name}"
      state         = "FAILED"
      topic_arn     = var.sns_topics.failed
      resource_arn  = r.arn
      resource_type = r.type
    }
  ]
  failed_map = { for d in local.failed_defs : d.key => d }

  # ---------- EXPIRED ----------
  expired_defs = [
    for key, r in local.norm_resources : {
      key           = "${key}_expired"
      rule_name     = substr("${var.resource_name_prefix}-${r.name}-backup-expired", 0, 64)
      description   = "AWS Backup job EXPIRED for ${r.name}"
      state         = "EXPIRED"
      topic_arn     = var.sns_topics.expired
      resource_arn  = r.arn
      resource_type = r.type
    }
  ]
  expired_map = { for d in local.expired_defs : d.key => d }
}

# =============== SUCCESS ===================

resource "aws_cloudwatch_event_rule" "backup_success" {
  for_each = local.success_map

  name        = each.value.rule_name
  description = each.value.description

  event_pattern = jsonencode({
    "source"      : ["aws.backup"],
    "detail-type" : ["Backup Job State Change"],
    "detail" : {
      "state"       : [each.value.state],
      "resourceArn" : [each.value.resource_arn]
      # we could also AND resourceType = each.value.resource_type if you really want
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "backup_success_sns" {
  for_each = aws_cloudwatch_event_rule.backup_success

  rule      = each.value.name
  target_id = "sns"
  arn       = local.success_map[each.key].topic_arn
}

# =============== FAILED ====================

resource "aws_cloudwatch_event_rule" "backup_failed" {
  for_each = local.failed_map

  name        = each.value.rule_name
  description = each.value.description

  event_pattern = jsonencode({
    "source"      : ["aws.backup"],
    "detail-type" : ["Backup Job State Change"],
    "detail" : {
      "state"       : [each.value.state],
      "resourceArn" : [each.value.resource_arn]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "backup_failed_sns" {
  for_each = aws_cloudwatch_event_rule.backup_failed

  rule      = each.value.name
  target_id = "sns"
  arn       = local.failed_map[each.key].topic_arn
}

# =============== EXPIRED ====================

resource "aws_cloudwatch_event_rule" "backup_expired" {
  for_each = local.expired_map

  name        = each.value.rule_name
  description = each.value.description

  event_pattern = jsonencode({
    "source"      : ["aws.backup"],
    "detail-type" : ["Backup Job State Change"],
    "detail" : {
      "state"       : [each.value.state],
      "resourceArn" : [each.value.resource_arn]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "backup_expired_sns" {
  for_each = aws_cloudwatch_event_rule.backup_expired

  rule      = each.value.name
  target_id = "sns"
  arn       = local.expired_map[each.key].topic_arn
}


#anchor extra alarm