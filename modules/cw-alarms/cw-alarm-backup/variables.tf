variable "resource_name_prefix" {
  description = "Client/env prefix used in rule names, e.g. anchor-prod"
  type        = string
}

variable "resources" {
  description = <<EOF
Map of resources protected by AWS Backup that you want per-resource alarms for.

Key is any logical name (e.g. "ec2_app_01", "rds_eastel_db").
Fields:
  - arn  : full resource ARN (EC2 instance ARN, RDS instance ARN, etc.)
  - name : used in rule naming: [prefix]-[name]-Backup-...
  - type : AWS Backup resourceType, e.g. "EC2", "RDS" (optional but nice for clarity)
EOF
  type = map(object({
    arn  = string
    name = string
    type = optional(string) # "EC2", "RDS", "EFS", ...
  }))
}

variable "sns_topics" {
  description = "SNS topics used for backup events"
  type = object({
    success = string
    failed  = string
    expired = string
  })
}

variable "tags" {
  description = "Tags for EventBridge rules"
  type        = map(string)
  default     = {}
}
