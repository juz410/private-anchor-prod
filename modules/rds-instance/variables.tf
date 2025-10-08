variable "rds_cmk_id" {
  type = string
}

variable "secret_manager_cmk_id" {
  type = string
}

variable "name" {
  type = string
}

variable "db_identifier" {
  type = string
}
variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_master_user_name" {
  type = string
}

variable "db_security_group_ids" {
  type = list(string)
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_storage_type" {
  type = string
}

variable "db_storage_size" {
  type = number
}

variable "db_storage_iops" {
  type = number
}

variable "db_storage_throughput" {
  type    = number
  default = 125
}

variable "db_multi_az" {
  type    = bool
  default = true
}
variable "db_public_access" {
  type    = bool
  default = false
}

variable "db_port" {
  type = number
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_copy_tags_to_snapshot" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "db_apply_immediately" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = false
}

variable "db_final_snapshot_identifier" {
  type = string
}
#tag

variable "tags" {
  type = map(string)
}



#backups
variable "backup_tag_prefix" {
  type    = string
  default = "anchor-backup" # results in keys like aws-backup:hourly
}
#anchor-backup

variable "backup_8hourly" {
  type    = bool
  default = false
}

variable "backup_12hourly" {
  type    = bool
  default = false
}
variable "backup_daily" {
  type    = bool
  default = false
}

variable "backup_weekly" {
  type    = bool
  default = false
}

variable "backup_monthly" {
  type    = bool
  default = false
}

variable "backup_yearly" {
  type    = bool
  default = false
}