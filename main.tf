###############################################
# Locals: naming + global standard tags
###############################################
locals {
  resource_name_prefix = "${var.project_id}-${var.environment}"

  # Global standard tags (applied everywhere)
  standard_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    # CostCenter  = var.cost_center
  }
}

# (Optional but recommended) Auto-apply standard tags to all AWS resources
# provider "aws" {
#   region = var.region
#   default_tags { tags = local.standard_tags }
# }

###############################################
# VPC
###############################################
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                           = var.vpc_cidr
  public_subnet_a_cidr               = var.public_subnet_a_cidr
  public_subnet_b_cidr               = var.public_subnet_b_cidr
  private_kalsym_app_subnet_a_cidr   = var.private_kalsym_app_subnet_a_cidr
  private_kalsym_app_subnet_b_cidr   = var.private_kalsym_app_subnet_b_cidr
  private_kalsym_ecs_subnet_a_cidr   = var.private_kalsym_ecs_subnet_a_cidr
  private_kalsym_ecs_subnet_b_cidr   = var.private_kalsym_ecs_subnet_b_cidr
  private_kalsym_db_subnet_a_cidr    = var.private_kalsym_db_subnet_a_cidr
  private_kalsym_db_subnet_b_cidr    = var.private_kalsym_db_subnet_b_cidr
  private_internal_alb_subnet_a_cidr = var.private_internal_alb_subnet_a_cidr
  private_internal_alb_subnet_b_cidr = var.private_internal_alb_subnet_b_cidr
  private_multibyte_subnet_a_cidr    = var.private_multibyte_subnet_a_cidr
  private_multibyte_subnet_b_cidr    = var.private_multibyte_subnet_b_cidr
  private_multibyte_db_subnet_a_cidr = var.private_multibyte_db_subnet_a_cidr
  private_multibyte_db_subnet_b_cidr = var.private_multibyte_db_subnet_b_cidr
  private_tgw_subnet_a_cidr          = var.private_tgw_subnet_a_cidr
  private_tgw_subnet_b_cidr          = var.private_tgw_subnet_b_cidr
  tgw_id                             = var.tgw_id

  resource_name_prefix = local.resource_name_prefix

  tags = merge(
    local.standard_tags
  )
}

module "vpc_flowlogs" {
  source                   = "./modules/vpc-flowlogs"
  vpc_id                   = module.vpc.main_vpc_id
  vpc_name                 = module.vpc.main_vpc_name
  flow_logs_kms_key_id     = data.aws_kms_key.cloudwatch_logs_cmk.arn
  resource_name_prefix     = local.resource_name_prefix
  flow_logs_retention_days = 365


  tags = merge(
    local.standard_tags
  )
}

module "hk_vpc" {
  source                    = "./modules/vpc-hk"
  vpc_cidr                  = "10.20.16.0/24"
  private_dra_subnet_a_cidr = "10.20.16.0/28"
  private_dra_subnet_b_cidr = "10.20.16.16/28"
  private_tgw_subnet_a_cidr = "10.20.16.32/28"
  private_tgw_subnet_b_cidr = "10.20.16.48/28"
  resource_name_prefix      = local.resource_name_prefix

  tgw_id = var.tgw_id

  tags = merge(
    local.standard_tags
  )
}

module "hk_vpc_flowlogs" {
  source                   = "./modules/vpc-flowlogs"
  vpc_id                   = module.hk_vpc.main_vpc_id
  vpc_name                 = module.hk_vpc.main_vpc_name
  flow_logs_kms_key_id     = data.aws_kms_key.cloudwatch_logs_cmk.arn
  resource_name_prefix     = local.resource_name_prefix
  flow_logs_retention_days = 365
  tags = merge(
    local.standard_tags
  )
}




###############################################
# Security Groups
###############################################
module "security_groups" {
  source                           = "./modules/security-groups"
  vpc_id                           = module.vpc.main_vpc_id
  vpc_hk_id                        = module.hk_vpc.main_vpc_id
  private_kalsym_ecs_subnet_a_cidr = var.private_kalsym_ecs_subnet_a_cidr
  private_kalsym_ecs_subnet_b_cidr = var.private_kalsym_ecs_subnet_b_cidr
  main_vpc_cidr                    = var.vpc_cidr
  hk_vpc_cidr                      = module.hk_vpc.vpc_cidr
  testbed_vpc_cidr                 = "10.100.8.0/22"

  resource_name_prefix = local.resource_name_prefix

  tags = merge(
    local.standard_tags
  )
}

###############################################
# VPC Endpoints
###############################################
module "endpoints" {
  source             = "./modules/endpoints"
  vpc_id             = module.vpc.main_vpc_id
  security_group_ids = [module.security_groups.interface_endpoint_sg_id]
  subnet_ids = [
    module.vpc.private_kalsym_app_subnet_a_id,
    module.vpc.private_kalsym_app_subnet_b_id,
  ]

  resource_name_prefix = local.resource_name_prefix

  gateway_route_table_ids = [module.vpc.private_route_table_id]

  tags = merge(
    local.standard_tags
  )
}

###############################################
# IAM
###############################################
module "iam" {
  source = "./modules/iam"

  resource_name_prefix = local.resource_name_prefix

  tags = merge(
    local.standard_tags
  )

  #aws backup alarm 
  event_bridge_sns_topic_arns = {
    success = module.sns_monitoring.topic_arns["backup_success"]
    failed  = module.sns_monitoring.topic_arns["backup_failed"]
    expired = module.sns_monitoring.topic_arns["backup_expired"]
    instance_state = module.sns_monitoring.topic_arns["instance_state"]
        rds_events        = module.sns_monitoring.topic_arns["rds_event"]

  }

}

###############################################
# EC2 Instances
###############################################
module "ec2_instances" {
  for_each = local.ec2_servers
  source   = "./modules/ec2-instances"

  name                 = "${local.resource_name_prefix}-${each.value.name_suffix}"
  ami                  = each.value.ami
  instance_type        = each.value.instance_type
  subnet_id            = each.value.subnet_id
  security_group_ids   = each.value.security_group_ids
  iam_instance_profile = module.iam.ec2_instance_profile_name
  # iam_instance_profile = each.value.iam_instance_profile

  # Root volume
  root_volume_size           = try(each.value.root_volume_size, 30)
  root_volume_type           = try(each.value.root_volume_type, "gp3")
  root_volume_throughput     = try(each.value.root_volume_throughput, 125)
  root_volume_iops           = try(each.value.root_volume_iops, 3000)
  root_delete_on_termination = try(each.value.root_delete_on_termination, true)
  root_kms_key_id            = try(each.value.root_kms_key_id, null)

  # Extra EBS volumes (optional)
  ebs_block_devices = try(each.value.ebs_block_devices, [])

  # Networking / ops
  associate_public_ip        = try(each.value.associate_public_ip, false)
  key_name                   = try(each.value.key_name, null)
  private_ip                 = try(each.value.private_ip, null)
  secondary_private_ips      = try(each.value.secondary_private_ips, null)
  source_dest_check          = try(each.value.source_dest_check, true)
  enable_detailed_monitoring = try(each.value.enable_detailed_monitoring, false)
  disable_api_termination    = try(each.value.disable_api_termination, false)
  enable_hibernation         = try(each.value.enable_hibernation, false)
  placement_tenancy          = try(each.value.placement_tenancy, "default")

  # User data (you’re already constructing this in locals per-instance)
  user_data = try(each.value.user_data, "")

  # Backup tags/flags
  backup_tag_prefix = try(each.value.backup_tag_prefix, "anchor-backup")
  backup_8hourly    = try(each.value.backup_8hourly, false)
  backup_12hourly   = try(each.value.backup_12hourly, false)
  backup_daily      = try(each.value.backup_daily, false)
  backup_weekly     = try(each.value.backup_weekly, false)
  backup_monthly    = try(each.value.backup_monthly, false)
  backup_yearly     = try(each.value.backup_yearly, false)

  tags = merge(
    local.standard_tags
  )
}

module "external_alb" {
  source             = "./modules/alb-external"
  vpc_id             = module.vpc.main_vpc_id
  subnet_ids         = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
  security_group_ids = [module.security_groups.external_alb_sg_id]

  ec2_instance_ids = {
    #testingonly
    ussd_server01 = module.ec2_instances["ussd_server_01"].ec2_instance_id
    # all_in_one_server_id   = module.ec2_instances["all_in_one_server"].ec2_instance_id
  }

  resource_name_prefix  = local.resource_name_prefix
  lb_access_logs_bucket = data.aws_s3_bucket.lb_access_logs_bucket.bucket
  current_account_id    = data.aws_caller_identity.current.account_id

  tags = merge(
    local.standard_tags
  )
}

module "external_nlb" {
  source             = "./modules/nlb"
  vpc_id             = module.vpc.main_vpc_id
  subnet_ids         = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
  security_group_ids = [module.security_groups.external_nlb_sg_id]
  target_alb_arn     = module.external_alb.external_alb_arn

  resource_name_prefix = local.resource_name_prefix

  lb_access_logs_bucket = data.aws_s3_bucket.lb_access_logs_bucket.bucket
  current_account_id    = data.aws_caller_identity.current.account_id

  tags = merge(
    local.standard_tags
  )
}

module "internal_alb" {
  source             = "./modules/alb-internal"
  vpc_id             = module.vpc.main_vpc_id
  subnet_ids         = [module.vpc.private_internal_alb_subnet_a_id, module.vpc.private_internal_alb_subnet_b_id]
  security_group_ids = [module.security_groups.internal_alb_sg_id]

  ec2_instance_ids = {
    iot_web_frontend_server_01 = module.ec2_instances["iot_web_frontend_server_01"].ec2_instance_id
    iot_web_frontend_server_02 = module.ec2_instances["iot_web_frontend_server_02"].ec2_instance_id
  }

  resource_name_prefix = local.resource_name_prefix

  lb_access_logs_bucket = data.aws_s3_bucket.lb_access_logs_bucket.bucket
  current_account_id    = data.aws_caller_identity.current.account_id

  tags = merge(
    local.standard_tags
  )
}






#db
module "multibyte_db_subnet_group" {
  source     = "./modules/rds-subnets-group"
  subnet_ids = [module.vpc.private_multibyte_db_subnet_a_id, module.vpc.private_multibyte_db_subnet_b_id]
  name       = "${local.resource_name_prefix}-multibyte-db-subnet-group"

  tags = merge(
    local.standard_tags
  )
}



module "multibyte_db_rds_postgresql" {
  source = "./modules/rds-instance"

  # ---- Naming ----
  name          = "${local.resource_name_prefix}-eastel-bss-db"
  db_identifier = "${local.resource_name_prefix}-eastel-bss-db"

  # ---- Engine ----
  db_engine         = "postgres"
  db_engine_version = 15.15

  # ---- Instance Sizing ----
  db_instance_class     = "db.m7i.xlarge"
  db_storage_type       = "gp3"
  db_storage_size       = 500
  db_storage_iops       = 12000
  db_storage_throughput = 500

  # ---- Networking ----
  db_subnet_group_name  = module.multibyte_db_subnet_group.db_subnet_group_name
  db_security_group_ids = [module.security_groups.multibyte_postgresql_db_server_sg_id]
  db_multi_az           = true
  db_public_access      = false
  db_port               = 5432

  # ---- Authentication ----
  db_master_user_name   = "masteruser"
  secret_manager_cmk_id = data.aws_kms_key.secret_manager_cmk.arn
  rds_cmk_id            = data.aws_kms_key.rds_cmk.arn


  # ---- Backup & Protection ----
  db_backup_retention_period    = null # AWS Backup manages retention
  db_copy_tags_to_snapshot      = false
  db_deletion_protection        = false
  db_auto_minor_version_upgrade = true

  # ---- Apply & Maintenance ----
  db_apply_immediately               = true
  db_skip_final_snapshot             = true
  db_final_snapshot_identifier       = "${local.resource_name_prefix}-eastel-bss-db-final-snapshot-postgresql15"
  db_enabled_cloudwatch_logs_exports = ["iam-db-auth-error", "postgresql", "upgrade"]
  db_parameter_group_name = data.aws_db_parameter_group.multibyte_db_rds_postgresql15_parameter_group.name
  # You can set skip_final_snapshot = true in non-prod



  # ---- Backup Tagging ----
  backup_tag_prefix = "anchor-backup"
  backup_8hourly    = true
  backup_12hourly   = true # This one will get picked up by AWS Backup plan
  backup_daily      = true
  backup_weekly     = true
  backup_monthly    = true
  backup_yearly     = true

  # ---- Global Variables ----
  tags = merge(
    local.standard_tags
  )
}

module "kalsym_db_subnet_group" {
  source     = "./modules/rds-subnets-group"
  subnet_ids = [module.vpc.private_kalsym_db_subnet_a_id, module.vpc.private_kalsym_db_subnet_b_id]
  name       = "${local.resource_name_prefix}-kalsym-db-subnet-group"

  tags = merge(
    local.standard_tags
  )
}

module "kalsym_db_rds_mysql" {
  source = "./modules/rds-instance"

  # ---- Naming ----
  name          = "${local.resource_name_prefix}-eastel-db"
  db_identifier = "${local.resource_name_prefix}-eastel-db"

  # ---- Engine ----
  db_engine         = "mysql"
  db_engine_version = data.aws_rds_engine_version.mysql_latest.version

  # ---- Instance Sizing ----
  db_instance_class     = "db.m7i.large"
  db_storage_type       = "gp3"
  db_storage_size       = 300
  db_storage_iops       = null
  db_storage_throughput = null

  # ---- Networking ----
  db_subnet_group_name  = module.kalsym_db_subnet_group.db_subnet_group_name
  db_security_group_ids = [module.security_groups.kalsym_mysql_db_server_sg_id]
  db_multi_az           = true
  db_public_access      = false
  db_port               = 3306

  # ---- Authentication ----
  db_master_user_name   = "masteruser"
  secret_manager_cmk_id = data.aws_kms_key.secret_manager_cmk.arn
  rds_cmk_id            = data.aws_kms_key.rds_cmk.arn

  # ---- Backup & Protection ----
  db_backup_retention_period    = null # AWS Backup manages retention
  db_copy_tags_to_snapshot      = false
  db_deletion_protection        = true
  db_auto_minor_version_upgrade = true

  # ---- Apply & Maintenance ----
  db_apply_immediately         = false
  db_skip_final_snapshot       = true
  db_final_snapshot_identifier = "${local.resource_name_prefix}-eastel-db-final-snapshot"
  # You can set skip_final_snapshot = true in non-prod
  db_enabled_cloudwatch_logs_exports = ["audit", "error", "general", "iam-db-auth-error", "slowquery"]



  # ---- Backup Tagging ----
  backup_tag_prefix = "anchor-backup"
  backup_8hourly    = true
  backup_12hourly   = true # This one will get picked up by AWS Backup plan
  backup_daily      = true
  backup_weekly     = true
  backup_monthly    = true
  backup_yearly     = true

  # ---- Global Variables ----
  tags = merge(
    local.standard_tags
  )
}

module "mongodb_endpoint" {
  source             = "./modules/mongodb-endpoint"
  vpc_id             = module.vpc.main_vpc_id
  security_group_ids = [module.security_groups.mongodb_endpoint_sg_id]
  subnet_ids = [
    module.vpc.private_kalsym_ecs_subnet_a_id,
    module.vpc.private_kalsym_ecs_subnet_b_id,
  ]

  resource_name_prefix = local.resource_name_prefix

  tags = merge(
    local.standard_tags
  )
}



#------------------ ALARM ----------------------#
module "sns_monitoring" {
  source = "./modules/sns"
  tags   = local.standard_tags
  kms_key_arn = data.aws_kms_key.sns_cmk.arn

  topics = {
    # EC2
    cpu = {
      name          = "gap-cpu-topic"
      display_name  = "${local.resource_name_prefix}-cpu-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    memory = {
      name          = "gap-memory-topic"
      display_name  = "${local.resource_name_prefix}-memory-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    disk = {
      name          = "gap-disk-topic"
      display_name  = "${local.resource_name_prefix}-low-disk-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    statuscheck = {
      name          = "gap-status-check-topic"
      display_name  = "${local.resource_name_prefix}-status-check-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    #ec2_instance Anchor extra
    instance_state = {
      name          = "gap-instance-state-topic"
      display_name  = "${local.resource_name_prefix}-instancestate-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

  # --- RDS standard ---
    rds_storage = {
      name          = "gap-rds-storage-topic"
      display_name  = "${local.resource_name_prefix}-rds-storage-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    # --- RDS extra ---
    rds_cpu = {
      name          = "gap-rds-cpu-topic"
      display_name  = "${local.resource_name_prefix}-rds-cpu-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    rds_connection = {
      name          = "gap-rds-connection-topic"
      display_name  = "${local.resource_name_prefix}-rds-connection-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    rds_event = {
      name          = "gap-rds-event-topic"
      display_name  = "${local.resource_name_prefix}-rds-event-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    #ECS

    ecs_running_task = {
      # from sheet: GAP_RunningTaskCount_topic
      name          = "gap-runningtaskcount-topic"
      display_name  = "${local.resource_name_prefix}-running-task-count-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    ecs_pending_task = {
      # GAP_PendingTaskCount_topic
      name          = "gap-pendingtaskcount-topic"
      display_name  = "${local.resource_name_prefix}-pending-task-count-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    ecs_service_cpu = {
      # GAP_ServiceCPUUtilization_topic
      name          = "gap-servicecpuutilization-topic"
      display_name  = "${local.resource_name_prefix}-service-cpu-utilization-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    ecs_service_memory = {
      # GAP_ServiceMemoryUtilization_Topic
      name          = "gap-servicememoryutilization-topic"
      display_name  = "${local.resource_name_prefix}-service-memory-utilization-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    

    # --- AWS Backup ---
    backup_success = {
      name          = "gap-backup-success-topic"
      display_name  = "${local.resource_name_prefix}-backup-success"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    },{
      protocol = "email"
      endpoint = "kokfeeng.tan@g-asiapac.com"
    }
    ]
    }
    backup_failed = {
      name          = "gap-backup-failed-topic"
      display_name  = "${local.resource_name_prefix}-backup-failed"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    backup_expired = {
      name          = "gap-backup-expired-topic"
      display_name  = "${local.resource_name_prefix}-backup-expired"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    # NLB extra alarms
    nlb_tcp_client_reset = {
      name          = "gap-nlb-tcptargetresetcount-topic"
      display_name  = "${local.resource_name_prefix}-tcp-target-reset-count-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
    nlb_tcp_elb_reset = {
      name          = "gap-nlb-tcpelbresetcount-topic"
      display_name  = "${local.resource_name_prefix}-tcp-elb-reset-count-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    #ALB extra alarms
    alb_healthyhost = {
      name          = "gap-alb-healthyhostcount-topic"
      display_name  = "${local.resource_name_prefix}-healthy-host-count-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }] # or add email subscriptions like your other topics
    }

    alb_target_5xx = {
      name          = "gap-alb-httpcode-target-5xx-topic"
      display_name  = "${local.resource_name_prefix}-HTTPCodeTarget5XXCount-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }

    alb_elb_5xx = {
      name          = "gap-alb-httpcode-elb-5xx-topic"
      display_name  = "${local.resource_name_prefix}-HTTPCodeELB5XXCount-alarm"
      subscriptions = [{
      protocol = "email"
      endpoint = "noc@eastel.com.my"
    }]
    }
  }
}

locals {
  ec2_alarm_instances = {
    for k, m in module.ec2_instances : k => {
      instance_id   = m.ec2_instance_id
      instance_name = m.name
      instance_type = m.instance_type

      # YOU must define these to match CWAgent’s actual disk dimensions.
      # Example only (change to your real /apps, device, fstype):
      disk_targets = try(local.ec2_servers[k].disk_targets, [{ path = "/", device = "nvme0n1p1", fstype = "xfs", label = "root" }])

    }
  }
}

module "ec2_standard_alarms" {
  source               = "./modules/cw-alarms/cw-alarm-ec2"
  resource_name_prefix = local.resource_name_prefix
  instances            = local.ec2_alarm_instances

  sns_topics = {
    cpu         = module.sns_monitoring.topic_arns["cpu"]
    memory      = module.sns_monitoring.topic_arns["memory"]
    statuscheck = module.sns_monitoring.topic_arns["statuscheck"]
    disk        = module.sns_monitoring.topic_arns["disk"]
  }

  tags = local.standard_tags
}

locals {
  rds_alarm_instances = {
    eastel_bss_db = {
      db_identifier       = module.multibyte_db_rds_postgresql.db_identifier
      instance_name       = module.multibyte_db_rds_postgresql.name
      conn_warn_threshold = 1450
      conn_crit_threshold = 1650
    }
    eastel_db = {
      db_identifier       = module.kalsym_db_rds_mysql.db_identifier
      instance_name       = module.kalsym_db_rds_mysql.name
      conn_warn_threshold = 550
      conn_crit_threshold = 620
    }
  }
}

module "rds_standard_alarms" {
  source               = "./modules/cw-alarms/cw-alarm-rds"
  resource_name_prefix = local.resource_name_prefix
  instances            = local.rds_alarm_instances

  sns_topics = {
    storage    = module.sns_monitoring.topic_arns["rds_storage"]
    cpu        = module.sns_monitoring.topic_arns["rds_cpu"]
    connection = module.sns_monitoring.topic_arns["rds_connection"]
    event      = module.sns_monitoring.topic_arns["rds_event"]
  }

  cpu_thresholds             = [80, 90]
  storage_free_gb_thresholds = [10, 5]

  tags = local.standard_tags
}

###############################################
# Lambda SNS Publisher for Backup and EC2 State Changes
###############################################
module "sns_publisher_shared" {
  source = "./modules/lambda-sns-publisher"

  resource_name_prefix = local.resource_name_prefix
  project_id = var.project_id
  environment = var.environment

  # Additional environment variables to pass to the Lambda function
  lambda_additional_env = {
    # Timezone offset in minutes, e.g. UTC+8 = 480, UTC-5 = -300, default is -480 (UTC-8 for Malaysia time). Adjust as needed in here or in the variable.
    TIMEZONE_OFFSET_MINUTES = tostring(var.timezone_offset_minutes)
  }

  topic_map = {
    success    = module.sns_monitoring.topic_arns["backup_success"]
    failed     = module.sns_monitoring.topic_arns["backup_failed"]
    expired    = module.sns_monitoring.topic_arns["backup_expired"]
    ec2_state  = module.sns_monitoring.topic_arns["instance_state"]
  }

  awsbackup_state_topic_mapping = {
    COMPLETED = "success"
    FAILED    = "failed"
    EXPIRED   = "expired"
  }
  sns_kms_key_arn = data.aws_kms_key.sns_cmk.arn
  current_account_id    = data.aws_caller_identity.current.account_id
  region = var.region
 
  ec2_state_topic_label   = "ec2_state"
  ec2_state_topic_mapping = {
    pending        = "ec2_state"
    running        = "ec2_state"
    stopping       = "ec2_state"
    stopped        = "ec2_state"
    "shutting-down" = "ec2_state"
    terminated     = "ec2_state"
  }

  # Optional: override templates here if desired, otherwise defaults in the Python code (see lambda-sns-publisher/lambda/index.py) will be used
  # Please use "_fmt" behind the variables related to time for time formatting in the Lambda code, e,g. {startTime_fmt}, {completionTime_fmt}
  # Please use "_date" behind the variables related to date for date formatting in the Lambda code, e,g. {startTime_date}

  # I have uncommented subject_template for AWS Backup as an example, you can do the same for EC2 if desired.
    subject_template     = "[BACKUP - {state}] : Project {project_id}-{environment} at {startTime_date}"

  #   message_template     = <<EOT
  # [Backup {state}]
  # Vault: {vault}
  # Resource: ({resourceType}) {resourceName}
  # Resource ARN: {resourceArn}
  # Plan: {planName} (Rule: {ruleName})
  # Backup Job ID: {jobId}
  # Start: {startTime_fmt}
  # End: {completionTime_fmt}
  # Category: {messageCategory}


  # JSON formatted details: {detail_json}
  # EOT
  # ec2_subject_template = "[EC2 {state}] Instance {instanceId}"
  # ec2_message_template = "..."

  tags = local.standard_tags
}

###############################################
# EC2 State Change EventBridge Alarms using the shared SNS Publisher Lambda
###############################################

# PREREQUESITE: Please set the variable "include_state_notifications = true" in local.ec2_servers for each instance you want to monitor, set to false or omit to skip.
locals {
  ec2_state_notification_instance_ids = [
    for key, mod in module.ec2_instances : mod.ec2_instance_id
    if try(local.ec2_servers[key].include_state_notifications, false)
      || (length(var.ec2_state_notification_instance_keys) == 0 ? false : contains(var.ec2_state_notification_instance_keys, key))
  ]
}

module "ec2_state_notifications" {
  source               = "./modules/cw-alarms/cw-ec2-state-change-alarm"
  resource_name_prefix = local.resource_name_prefix

  # If true, create the rule even when no instance IDs are provided (will match all instances). Defaults to false to avoid catching everything when nothing opted in.
  enable_when_no_instances = false

  instance_ids = local.ec2_state_notification_instance_ids

  lambda_function_arn  = module.sns_publisher_shared.function_arn
  lambda_function_name = module.sns_publisher_shared.function_name

  # Defaults cover all states; override if needed
  # ec2_state_values = ["running", "stopped", ...]

  tags = local.standard_tags
}

###############################################
# AWS Backups EventBridge Alarms using the shared SNS Publisher Lambda
###############################################
locals {
  backup_alarm_vaults = {
    default = {
      vault_name   = "anchor-primary-vault"
      display_name = "anchor-primary-vault"
    }
  # Add more vaults here if needed.
  #   second_vault = {
  #     vault_name   = "secondary-backup"
  #     display_name = "secondary-backup-displayname"
  # }
  }
}

module "backup_standard_alarms" {
  source               = "./modules/cw-alarms/cw-alarm-backup"
  resource_name_prefix = local.resource_name_prefix
  vaults               = local.backup_alarm_vaults

  lambda_function_arn  = module.sns_publisher_shared.function_arn
  lambda_function_name = module.sns_publisher_shared.function_name

  tags = local.standard_tags
}


# ##----- AWS Backup Alarm ------

# locals {
#   # EC2 resources protected by AWS Backup
#   backup_resources_ec2 = {
#     for k, m in module.ec2_instances : k => {
#       arn  = m.arn              # make sure ec2_instances module outputs this
#       name = m.name             # "anchor-prod-ussd-svr-01" etc.
#       type = "EC2"
#     }
#   }

#   # RDS resources
#   backup_resources_rds = {
#     eastel_bss_db = {
#       arn  = module.multibyte_db_rds_postgresql.arn
#       name = module.multibyte_db_rds_postgresql.name
#       type = "RDS"
#     }
#     eastel_db = {
#       arn  = module.kalsym_db_rds_mysql.arn
#       name = module.kalsym_db_rds_mysql.name
#       type = "RDS"
#     }
#   }

#   backup_resources = merge(
#     local.backup_resources_ec2,
#     local.backup_resources_rds
#   )
# }


# module "backup_alarms" {
#   source               = "./modules/cw-alarms/cw-alarm-backup"
#   resource_name_prefix = local.resource_name_prefix
#   resources            = local.backup_resources

#   sns_topics = {
#     success = module.sns_monitoring.topic_arns["backup_success"]
#     failed  = module.sns_monitoring.topic_arns["backup_failed"]
#     expired = module.sns_monitoring.topic_arns["backup_expired"]
#   }

#   tags = local.standard_tags
# }


#=============== NLB ALARM ==================

locals {
  nlb_alarm_targets = {
    external = {
      lb_dim  = module.external_nlb.nlb_arn_suffix  
      lb_name = module.external_nlb.nlb_name       
    }
  }
}

module "nlb_alarms" {
  source               = "./modules/cw-alarms/cw-alarm-nlb"
  resource_name_prefix = local.resource_name_prefix
  nlbs                 = local.nlb_alarm_targets

  sns_topics = {
    tcp_client_reset = module.sns_monitoring.topic_arns["nlb_tcp_client_reset"]
    tcp_elb_reset    = module.sns_monitoring.topic_arns["nlb_tcp_elb_reset"]
  }

  # Optional overrides 
  tcp_client_reset_threshold = 50
  tcp_elb_reset_threshold    = 20
  period_seconds             = 300
  evaluation_periods         = 4
  datapoints_to_alarm = 4

  tags = local.standard_tags
}

#============= ALB Alarm ============
locals {
  alb_alarm_lbs = {
    external = {
      lb_arn_suffix = module.external_alb.alb_arn_suffix
      name          = module.external_alb.name    # usually "${local.resource_name_prefix}-external-alb"
    }
    internal = {
      lb_arn_suffix = module.internal_alb.alb_arn_suffix
      name          = module.internal_alb.name
    }
  }
}

module "alb_standard_alarms" {
  source               = "./modules/cw-alarms/cw-alarm-alb"
  resource_name_prefix = local.resource_name_prefix
  load_balancers       = local.alb_alarm_lbs

  sns_topics = {
    healthy_host = module.sns_monitoring.topic_arns["alb_healthyhost"]
    target_5xx   = module.sns_monitoring.topic_arns["alb_target_5xx"]
    elb_5xx      = module.sns_monitoring.topic_arns["alb_elb_5xx"]
  }

  # 5-minute critical alarms, matching your sheet
  period_seconds              = 300
  evaluation_periods          = 1
  healthy_min_hosts           = 1
  target_5xx_count_threshold  = 5
  elb_5xx_count_threshold     = 5
  treat_missing_data          = "missing"

  tags = local.standard_tags
}
