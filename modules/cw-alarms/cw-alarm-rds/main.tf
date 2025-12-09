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

  #anchor extra
  # ---------- CPU alarms ----------
#   cpu_defs = flatten([
#     for db_key, db in var.instances : [
#       for thr in var.cpu_thresholds : {
#         key        = "${db_key}_cpu_${thr}"
#         alarm_name = substr("${var.resource_name_prefix}-${db.instance_name}-cpu-high-${thr}%", 0, 255)
#         threshold  = thr
#         topic_arn  = var.sns_topics.cpu
#         dimensions = { DBInstanceIdentifier = db.db_identifier }
#       }
#     ]
#   ])
#   cpu_map = { for d in local.cpu_defs : d.key => d }

#   # ---------- Connections alarms (COUNT) ----------
#   conn_defs = flatten([
#     for db_key, db in var.instances : [
#       for thr in var.connection_thresholds : {
#         key        = "${db_key}_conn_${thr}"
#         alarm_name = substr("${var.resource_name_prefix}-${db.instance_name}-connections-high-${thr}", 0, 255)
#         threshold  = thr
#         topic_arn  = var.sns_topics.connection
#         dimensions = { DBInstanceIdentifier = db.db_identifier }
#       }
#     ]
#   ])
#   conn_map = { for d in local.conn_defs : d.key => d }


}

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


# #anchor extra

# resource "aws_cloudwatch_metric_alarm" "cpu" {
#   for_each = local.cpu_map

#   alarm_name          = each.value.alarm_name
#   alarm_description   = "RDS CPU usage exceeded ${each.value.threshold}%"
#   namespace           = "AWS/RDS"
#   metric_name         = "CPUUtilization"
#   statistic           = "Average"
#   period              = var.period_seconds
#   evaluation_periods  = var.evaluation_periods
#   threshold           = each.value.threshold
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   unit                = "Percent"
#   treat_missing_data  = var.treat_missing_data

#   dimensions    = each.value.dimensions
#   alarm_actions = [each.value.topic_arn]

#   tags = var.tags
# }

# resource "aws_cloudwatch_metric_alarm" "connections" {
#   for_each = local.conn_map

#   alarm_name          = each.value.alarm_name
#   alarm_description   = "RDS connections high (>= ${each.value.threshold})"
#   namespace           = "AWS/RDS"
#   metric_name         = "DatabaseConnections"
#   statistic           = var.connection_statistic
#   period              = var.period_seconds
#   evaluation_periods  = var.evaluation_periods
#   threshold           = each.value.threshold
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   unit                = "Count"
#   treat_missing_data  = var.treat_missing_data

#   dimensions    = each.value.dimensions
#   alarm_actions = [each.value.topic_arn]

#   tags = var.tags
# }

