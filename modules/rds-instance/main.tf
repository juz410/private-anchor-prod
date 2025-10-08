locals {
  backup_tags = {
    "${var.backup_tag_prefix}8hourly"  = tostring(var.backup_8hourly)
    "${var.backup_tag_prefix}12hourly" = tostring(var.backup_12hourly)
    "${var.backup_tag_prefix}daily"    = tostring(var.backup_daily)
    "${var.backup_tag_prefix}weekly"   = tostring(var.backup_weekly)
    "${var.backup_tag_prefix}monthly"  = tostring(var.backup_monthly)
    "${var.backup_tag_prefix}monthly"  = tostring(var.backup_monthly)
  }
}



resource "aws_db_instance" "rds" {

  identifier             = var.db_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.db_security_group_ids

  # Storage (gp3)
  storage_type       = var.db_storage_type
  allocated_storage  = var.db_storage_size

  iops                = contains(["gp3", "io1", "io2"], var.db_storage_type) ? var.db_storage_iops : null
storage_throughput  = var.db_storage_type == "gp3" ? var.db_storage_throughput : null

  multi_az            = var.db_multi_az
  publicly_accessible = var.db_public_access
  port                = var.db_port

  # Auth – generated above; stored in Secrets Manager
  username                      = var.db_master_user_name
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.secret_manager_cmk_id

  # Backups & protection
  backup_retention_period    = var.db_backup_retention_period
  copy_tags_to_snapshot      = var.db_copy_tags_to_snapshot
  deletion_protection        = var.db_deletion_protection
  auto_minor_version_upgrade = var.db_auto_minor_version_upgrade

  # Encryption
  storage_encrypted = true
  kms_key_id        = var.rds_cmk_id

  # Safety
  apply_immediately         = var.db_apply_immediately
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : var.db_final_snapshot_identifier
  tags = merge(
    var.tags,
    local.backup_tags,
    { Name = var.name }
  )

  # Optional: hook up parameter group if you have one
  # parameter_group_name     = aws_db_parameter_group.pg.name
}