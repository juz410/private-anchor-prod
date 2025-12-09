variable "resource_name_prefix" {
  type = string
}

variable "instances" {
  description = "Map of RDS instances to alarm on"
  type = map(object({
    db_identifier = string # used in dimension DBInstanceIdentifier
    instance_name = string # used in alarm naming (your convention)
  }))
}

variable "sns_topics" {
  type = object({
    storage    = string

    #anchor extra
    # cpu        = string
    # connection = string
  })
}

variable "storage_free_gb_thresholds" {
  type    = list(number)
  default = [10, 5]
}

#anchor extra
variable "cpu_thresholds" {
  type    = list(number)
  default = [80, 90]
}



variable "connection_thresholds" {
  description = "DatabaseConnections is a COUNT. Put real numbers here (e.g., [200, 400])."
  type        = list(number)
  default     = [200, 400]
}

variable "connection_statistic" {
  description = "Average or Maximum are common"
  type        = string
  default     = "Maximum"
  validation {
    condition     = contains(["Average", "Maximum", "Minimum", "Sum", "SampleCount"], var.connection_statistic)
    error_message = "connection_statistic must be a valid CloudWatch statistic."
  }
}

variable "period_seconds" {
  type    = number
  default = 300
}

variable "evaluation_periods" {
  type    = number
  default = 1
}

variable "treat_missing_data" {
  type    = string
  default = "missing"
}

variable "tags" {
  type    = map(string)
  default = {}
}
