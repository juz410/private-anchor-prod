locals {
  # ---------- Storage alarms (GB left) using FreeStorageSpace (Bytes) ----------
  storage_defs = flatten([
    for db_key, db in var.instances : [
      for gb in var.storage_free_gb_thresholds : {
        key        = "${db_key}_storage_${gb}"
        alarm_name = substr("${var.resource_name_prefix}-${db.instance_name}-storage-left-${gb}GB", 0, 255)
        bytes_thr  = gb * 1024 * 1024 * 1024
        topic_arn  = var.sns_topics.storage
        dimensions = { DBInstanceIdentifier = db.db_identifier }
      }
    ]
  ])
  storage_map = { for d in local.storage_defs : d.key => d }

  # ---------- CPU alarms (anchor extra) ----------
  cpu_defs = flatten([
    for db_key, db in var.instances : [
      for thr in var.cpu_thresholds : {
        key        = "${db_key}_cpu_${thr}"
        alarm_name = substr("${var.resource_name_prefix}-${db.instance_name}-cpu-high-${thr}%", 0, 255)
        threshold  = thr
        topic_arn  = var.sns_topics.cpu
        dimensions = { DBInstanceIdentifier = db.db_identifier }
      }
    ]
  ])
  cpu_map = { for d in local.cpu_defs : d.key => d }

  # ---------- Connections alarms (COUNT, anchor extra) ----------
  conn_defs = flatten([
    for db_key, db in var.instances : [
      # 80% warning level
      for pair in [
        {
          thr   = db.conn_warn_threshold
          label = 80
        },
        {
          thr   = db.conn_crit_threshold
          label = 90
        }
        ] : {
        key        = "${db_key}_conn_${pair.label}"
        alarm_name = substr("${var.resource_name_prefix}-${db.instance_name}-connections-high-${pair.label}%", 0, 255)
        threshold  = pair.thr
        topic_arn  = var.sns_topics.connection
        dimensions = { DBInstanceIdentifier = db.db_identifier }
      }
      if pair.thr != null
    ]
  ])

  conn_map = { for d in local.conn_defs : d.key => d }

  # ---------- RDS Events (anchor extra – EventBridge -> SNS) ----------
  rds_event_defs = [
    for db_key, db in var.instances : {
      key           = "${db_key}_events"
      rule_name     = substr("${var.resource_name_prefix}-${db.instance_name}-rds-events", 0, 64)
      description   = "Important RDS events (failure / failover) for ${db.instance_name}"
      db_identifier = db.db_identifier
      topic_arn     = var.sns_topics.event
    }
  ]
  rds_event_map = { for d in local.rds_event_defs : d.key => d }
}

# --------- STORAGE ---------
resource "aws_cloudwatch_metric_alarm" "storage_left_gb" {
  for_each = local.storage_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "RDS storage low (FreeStorageSpace <= ${each.value.bytes_thr} bytes)"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.bytes_thr
  comparison_operator = "LessThanOrEqualToThreshold"
  unit                = "Bytes"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}

# --------- CPU (extra) ---------
resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each = local.cpu_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "RDS CPU usage exceeded ${each.value.threshold}%"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  unit                = "Percent"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}

# --------- Connections (extra) ---------
resource "aws_cloudwatch_metric_alarm" "connections" {
  for_each = local.conn_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "RDS connections high (>= ${each.value.threshold})"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = var.connection_statistic
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  unit                = "Count"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}

# --------- RDS Events (extra – EventBridge) ---------
resource "aws_cloudwatch_event_rule" "rds_events" {
  for_each = local.rds_event_map

  name        = each.value.rule_name
  description = each.value.description

  # Focus on DB instance failure/failover events for that DB
  event_pattern = jsonencode({
    "source" : ["aws.rds"],
    "detail-type" : ["RDS DB Instance Event"],
    "detail" : {
      "SourceIdentifier" : [each.value.db_identifier],
      "EventCategories" : ["failure", "failover"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "rds_events_sns" {
  for_each = aws_cloudwatch_event_rule.rds_events

  rule      = each.value.name
  target_id = "sns"
  arn       = local.rds_event_map[each.key].topic_arn
}
