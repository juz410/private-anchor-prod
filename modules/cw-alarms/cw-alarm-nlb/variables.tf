variable "resource_name_prefix" {
  type = string
}

variable "nlbs" {
  description = "Map of NLBs to alarm on"
  type = map(object({
    lb_dim  = string # value for CloudWatch 'LoadBalancer' dimension (net/name/hash)
    lb_name = string # friendly name used in alarm naming
  }))
}

variable "sns_topics" {
  description = "SNS topic ARNs used by NLB alarms"
  type = object({
    tcp_client_reset = string
    tcp_elb_reset    = string
  })
}

variable "tcp_client_reset_threshold" {
  description = "Threshold for TCP_Client_Reset_Count (per period)"
  type        = number
  default     = 20
}

variable "tcp_elb_reset_threshold" {
  description = "Threshold for TCP_ELB_Reset_Count (per period)"
  type        = number
  default     = 20
}

variable "period_seconds" {
  type    = number
  default = 300 # 5 minutes
}

variable "evaluation_periods" {
  type    = number
  default = 1
}

variable "datapoints_to_alarm" {
  type = number
  default = 1
}

variable "treat_missing_data" {
  type = string
  # For reset counts, 'notBreaching' is usually nicer than 'missing'
  default = "notBreaching"
}

variable "tags" {
  type    = map(string)
  default = {}
}
