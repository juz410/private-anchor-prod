#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}

# aws backup alarm #

variable "event_bridge_sns_topic_arns" {
  description = "SNS topic ARNs used for Even bridge events."
  type = object({
    success        = string
    failed         = string
    expired        = string
    instance_state = string
    rds_events     = string
  })
}



