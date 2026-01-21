variable "resource_name_prefix" {
  description = "Prefix used to build a default function name if function_name is not set"
  type        = string
}

variable "function_name" {
  description = "Optional explicit Lambda function name"
  type        = string
  default     = null
}

variable "topic_map" {
  description = "Map of label => SNS topic ARN"
  type        = map(string)
}

variable "awsbackup_state_topic_mapping" {
  description = "Map of event state => topic_map key"
  type        = map(string)
  default     = {}
}

variable "default_topic_label" {
  description = "Fallback topic_map key if state is unmapped"
  type        = string
  default     = null
}

variable "subject_template" {
  description = "Template for SNS subject (Python format placeholders). Leave null to use code default."
  type        = string
  default     = null
}

variable "message_template" {
  description = "Template for SNS message (Python format placeholders). Leave null to use code default."
  type        = string
  default     = null
}

variable "ec2_subject_template" {
  description = "Template for EC2 state-change SNS subject. Leave null to use code default."
  type        = string
  default     = null
}

variable "ec2_message_template" {
  description = "Template for EC2 state-change SNS message. Leave null to use code default."
  type        = string
  default     = null
}

variable "ec2_state_topic_label" {
  description = "Label in topic_map to use for EC2 state changes"
  type        = string
  default     = "ec2_state"
}

variable "ec2_state_topic_mapping" {
  description = "Map EC2 state => topic_map key"
  type        = map(string)
  default     = {}
}

variable "lambda_runtime" {
  type    = string
  default = "python3.11"
}

variable "lambda_memory_mb" {
  type    = number
  default = 256
}

variable "lambda_timeout_seconds" {
  type    = number
  default = 30
}

variable "lambda_additional_env" {
  description = "Extra environment variables for the publisher Lambda"
  type        = map(string)
  default     = {}
}

variable "sns_kms_key_arn" {
  type = string
  default = ""
}

variable "current_account_id" {
  type = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
  default = ""
}