locals {
  # ---------- TCP client reset count ----------
  tcp_client_defs = [
    for key, lb in var.nlbs : {
      key = "${key}_tcp_client_reset"
      # add "-nlb-" so these are clearly NLB alarms
      alarm_name = substr(
        "${var.resource_name_prefix}-${lb.lb_name}-nlb-TCPClientResetCount-high-${var.tcp_client_reset_threshold}",
        0,
        255
      )
      threshold  = var.tcp_client_reset_threshold
      topic_arn  = var.sns_topics.tcp_client_reset
      dimensions = { LoadBalancer = lb.lb_dim } # net/name/hash
    }
  ]
  tcp_client_map = { for d in local.tcp_client_defs : d.key => d }

  # ---------- TCP ELB reset count ----------
  tcp_elb_defs = [
    for key, lb in var.nlbs : {
      key = "${key}_tcp_elb_reset"
      alarm_name = substr(
        "${var.resource_name_prefix}-${lb.lb_name}-nlb-TCPELBResetCount-high-${var.tcp_elb_reset_threshold}",
        0,
        255
      )
      threshold  = var.tcp_elb_reset_threshold
      topic_arn  = var.sns_topics.tcp_elb_reset
      dimensions = { LoadBalancer = lb.lb_dim }
    }
  ]
  tcp_elb_map = { for d in local.tcp_elb_defs : d.key => d }
}


# =============== TCP_Client_Reset_Count ====================

resource "aws_cloudwatch_metric_alarm" "tcp_client_reset" {
  for_each = local.tcp_client_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "NLB TCP_Client_Reset_Count > ${each.value.threshold} in ${var.period_seconds / 60} minutes"
  namespace           = "AWS/NetworkELB"
  metric_name         = "TCP_Client_Reset_Count"
  statistic           = "Sum"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanThreshold"
  unit                = "Count"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}

# =============== TCP_ELB_Reset_Count ======================

resource "aws_cloudwatch_metric_alarm" "tcp_elb_reset" {
  for_each = local.tcp_elb_map

  alarm_name          = each.value.alarm_name
  alarm_description   = "NLB TCP_ELB_Reset_Count > ${each.value.threshold} in ${var.period_seconds / 60} minutes"
  namespace           = "AWS/NetworkELB"
  metric_name         = "TCP_ELB_Reset_Count"
  statistic           = "Sum"
  period              = var.period_seconds
  evaluation_periods  = var.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanThreshold"
  unit                = "Count"
  treat_missing_data  = var.treat_missing_data

  dimensions    = each.value.dimensions
  alarm_actions = [each.value.topic_arn]

  tags = var.tags
}
