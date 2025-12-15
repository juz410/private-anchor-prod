#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}

# aws backup alarm #

variable "backup_sns_topic_arns" {
  description = "SNS topic ARNs used for AWS Backup events."
  type = object({
    success = string
    failed  = string
    expired = string
  })
}



