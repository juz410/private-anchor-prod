###############################################
# Locals: naming + global standard tags
###############################################
locals {
  resource_name_prefix = "${var.project}-${var.environment}"

  # Global standard tags (applied everywhere)
  standard_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    CostCenter  = var.cost_center
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

###############################################
# Security Groups
###############################################
module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.main_vpc_id

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
}

###############################################
# EC2 Instances
###############################################
module "ec2_instances" {
  for_each = local.ec2_servers
  source   = "./modules/ec2-instances"

  name                 = "${local.resource_name_prefix}-ec2-${each.value.name_suffix}"
  ami                  = each.value.ami
  instance_type        = each.value.instance_type
  subnet_id            = each.value.subnet_id
  security_group_ids   = each.value.security_group_ids
  iam_instance_profile = module.iam.ec2_instance_profile_name

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
  backup_8hourly     = try(each.value.backup_8hourly, false)
  backup_12hourly     = try(each.value.backup_12hourly, false)
  backup_daily      = try(each.value.backup_daily, false)
  backup_weekly     = try(each.value.backup_weekly, false)
  backup_monthly    = try(each.value.backup_monthly, false)
  backup_yearly    = try(each.value.backup_yearly, false)

  tags = merge(
    local.standard_tags
  )
}
