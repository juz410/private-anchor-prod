variable "resource_name_prefix" {
  type = string
}

variable "load_balancers" {
  description = <<EOF
Map of ALB resources to alarm on.

Key: any logical name (e.g. "external", "internal").
Fields:
  - lb_arn_suffix : ApplicationELB arn_suffix, e.g. "app/anchor-prod-external-alb/7dda855d0..."
  - name          : Friendly name used in alarm naming, e.g. "external-alb"
EOF
  type = map(object({
    lb_arn_suffix = string
    name          = string
  }))
}

variable "sns_topics" {
  description = "SNS topic ARNs for ALB alarms"
  type = object({
    healthy_host = string
    target_5xx   = string
    elb_5xx      = string
  })
}

variable "period_seconds" {
  type    = number
  default = 300 # 5 minutes
}

variable "evaluation_periods" {
  type    = number
  default = 1
}

variable "treat_missing_data" {
  type    = string
  default = "missing"
}

# ---------- Thresholds ----------

# “ALB unhealthy host high (5min)” -> HealthyHostCount < min_healthy_hosts
variable "healthy_min_hosts" {
  description = "Minimum HealthyHostCount before we treat it as 'unhealthy host high'"
  type        = number
  default     = 1
}

# These are *absolute* counts per 5 minutes.
# If you want them to reflect roughly “5%” you tune them per-environment.
variable "target_5xx_count_threshold" {
  description = "Threshold for HTTPCode_Target_5XX_Count (Sum over period)"
  type        = number
  default     = 5
}

variable "elb_5xx_count_threshold" {
  description = "Threshold for HTTPCode_ELB_5XX_Count (Sum over period)"
  type        = number
  default     = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}
