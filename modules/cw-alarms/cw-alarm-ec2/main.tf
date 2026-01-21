locals {
  # ---------- CPU alarms ----------
  cpu_defs = flatten([
    for inst_key, inst in var.instances : [
      for thr in var.cpu_thresholds : {
        key        = "${inst_key}_cpu_${thr}"
        alarm_name = "${var.resource_name_prefix}-${inst.instance_name}-cpu-high-${thr}%"
        threshold  = thr
        topic_arn  = var.sns_topics.cpu
        dimensions = { InstanceId = inst.instance_id }
      }
    ]
  ])
  cpu_map = { for d in local.cpu_defs : d.key => d }

  # ---------- Memory alarms ----------
  mem_defs = flatten([
    for inst_key, inst in var.instances : [
      for thr in var.memory_thresholds : {
        key        = "${inst_key}_mem_${thr}"
        alarm_name = "${var.resource_name_prefix}-${inst.instance_name}-memory-high-${thr}%"
        threshold  = thr
        topic_arn  = var.sns_topics.memory
        dimensions = { InstanceId = inst.instance_id }
      }
    ]
  ])
  mem_map = { for d in local.mem_defs : d.key => d }

  # ---------- StatusCheckFailed (either) ----------
  status_defs = {
    for inst_key, inst in var.instances :
    "${inst_key}_status_either" => {
      alarm_name = "${var.resource_name_prefix}-${inst.instance_name}-status-check-failed-either"
      topic_arn  = var.sns_topics.statuscheck
      dimensions = { InstanceId = inst.instance_id }
    }
  }

  # ---------- Disk % free via disk_used_percent ----------
  # Low-10% free => used >= 90 ; Low-5% free => used >= 95
  disk_pct_defs = flatten([
    for inst_key, inst in var.instances : [
      for d in try(inst.disk_targets, []) : [
        for free_thr in var.disk_free_percent_thresholds : {
          key        = "${inst_key}_diskpct_${try(d.label, d.device)}_${free_thr}"
          label      = try(d.label, d.device)
          used_thr   = 100 - free_thr
          alarm_name = "${var.resource_name_prefix}-${inst.instance_name}-disk-${try(d.label, d.device)}-low-${free_thr}%"
          topic_arn  = var.sns_topics.disk
          dimensions = {
            InstanceId = inst.instance_id
            path       = d.path
            device     = d.device
            fstype     = d.fstype
          }
        }
      ]
    ]
  ])
  disk_pct_map = { for x in local.disk_pct_defs : x.key => x }

  # ---------- Disk GB left via disk_free (Bytes) ----------
  disk_gb_defs = flatten([
    for inst_key, inst in var.instances : [
      for d in try(inst.disk_targets, []) : [
        for gb in var.disk_free_gb_thresholds : {
          key        = "${inst_key}_diskgb_${try(d.label, d.device)}_${gb}"
          alarm_name = "${var.resource_name_prefix}-${inst.instance_name}-disk-${try(d.label, d.device)}-left-${gb}GB"
          bytes_thr  = gb * 1024 * 1024 * 1024
          topic_arn  = var.sns_topics.disk
          dimensions = {
            InstanceId = inst.instance_id
            path       = d.path
            device     = d.device
            fstype     = d.fstype
          }
        }
      ]
    ]
  ])
  disk_gb_map = { for x in local.disk_gb_defs : x.key => x }


  # # anchor extra
  #   # ---------- Instance state-change events (EventBridge -> SNS) ----------
  #   inst_state_defs = [
  #     for inst_key, inst in var.instances : {
  #       key         = "${inst_key}_statechange"
  #       rule_name   = substr("${var.resource_name_prefix}-${inst.instance_name}-instancestate-change", 0, 64)
  #       description = "EC2 instance state change for ${inst.instance_name} (${inst.instance_id})"
  #       instance_id = inst.instance_id
  #       topic_arn   = var.sns_topics.instance_state
  #     }
  #   ]
  #   inst_state_map = { for d in local.inst_state_defs : d.key => d }
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each = local.cpu_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "CPU usage exceeded ${each.value.threshold}%"
  namespace           = "AWS/EC2"
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

resource "aws_cloudwatch_metric_alarm" "memory" {
  for_each = local.mem_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "Memory usage exceeded ${each.value.threshold}%"
  namespace           = var.cwagent_namespace
  metric_name         = "mem_used_percent"
  statistic           = "Maximum"
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



resource "aws_cloudwatch_metric_alarm" "disk_low_percent_free" {
  for_each = local.disk_pct_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "Disk free below threshold (implemented as disk_used_percent >= ${each.value.used_thr}%)"
  namespace           = var.cwagent_namespace
  metric_name         = "disk_used_percent"
  statistic           = "Maximum"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.used_thr
  comparison_operator = "GreaterThanOrEqualToThreshold"
  unit                = "Percent"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_left_gb" {
  for_each = local.disk_gb_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "Disk free space low (disk_free <= ${each.value.bytes_thr} bytes)"
  namespace           = var.cwagent_namespace
  metric_name         = "disk_free"
  statistic           = "Minimum" # important for “free space low”
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



resource "aws_cloudwatch_metric_alarm" "statuscheck_either" {
  for_each = local.status_defs

  alarm_name          = each.value.alarm_name
  alarm_description   = "EC2 status check failed (either system or instance)"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  unit                = "Count"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}


#Anchor extra

# =============== Instance State Change (EventBridge) ====================

# resource "aws_cloudwatch_event_rule" "instance_state_change" {
#   for_each = local.inst_state_map

#   name        = each.value.rule_name
#   description = each.value.description

#   # Fire on ANY state change for that specific instance
#   event_pattern = jsonencode({
#     "source"      : ["aws.ec2"],
#     "detail-type" : ["EC2 Instance State-change Notification"],
#     "detail" : {
#       "instance-id" : [each.value.instance_id]
#       # If later you want only certain states:
#       # "state" : ["running", "stopped", "stopping", "pending", "shutting-down", "terminated"]
#     }
#   })

#   tags = var.tags
# }

# resource "aws_cloudwatch_event_target" "instance_state_change_sns" {
#   for_each = aws_cloudwatch_event_rule.instance_state_change

#   rule      = each.value.name
#   target_id = "sns"
#   arn       = local.inst_state_map[each.key].topic_arn
# }