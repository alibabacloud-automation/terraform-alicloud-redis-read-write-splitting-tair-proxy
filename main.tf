# Get current region and account information
data "alicloud_regions" "current" {
  current = true
}

# Define default installation script for Redis client
locals {
  default_redis_install_script = <<-EOF
#!/bin/bash
export ROS_DEPLOY=true
curl -fsSL https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/install-script/read-write-splitting-through-tair-proxy/install.sh | bash
EOF
}

# Create VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
}

# Create VSwitch
resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_config.cidr_block
  zone_id      = var.vswitch_config.zone_id
  vswitch_name = var.vswitch_config.vswitch_name
}

# Create Security Group
resource "alicloud_security_group" "ecs_security_group" {
  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = var.security_group_config.security_group_name
  security_group_type = var.security_group_config.security_group_type
}

# Create Security Group Rules
resource "alicloud_security_group_rule" "rules" {
  for_each = {
    for rule in var.security_group_rules :
    "${rule.type}-${rule.ip_protocol}-${rule.port_range}" => rule
  }

  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
  security_group_id = alicloud_security_group.ecs_security_group.id
}

# Create Redis (Tair) instance with read-write splitting
resource "alicloud_kvstore_instance" "redis" {
  db_instance_name = var.kvstore_config.db_instance_name
  instance_class   = var.kvstore_config.instance_class
  engine_version   = var.kvstore_config.engine_version
  password         = var.kvstore_config.password
  payment_type     = var.kvstore_config.payment_type
  vswitch_id       = alicloud_vswitch.vswitch.id
  zone_id          = alicloud_vswitch.vswitch.zone_id
  read_only_count  = var.kvstore_config.read_only_count
  security_ips     = var.kvstore_config.security_ips
}

# Create ECS instance
resource "alicloud_instance" "ecs_instance" {
  instance_name              = var.instance_config.instance_name
  system_disk_category       = var.instance_config.system_disk_category
  system_disk_size           = var.instance_config.system_disk_size
  image_id                   = var.instance_config.image_id
  vswitch_id                 = alicloud_vswitch.vswitch.id
  password                   = var.instance_config.password
  instance_type              = var.instance_config.instance_type
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
  security_groups            = [alicloud_security_group.ecs_security_group.id]
}

# Create ECS command for Redis client installation
resource "alicloud_ecs_command" "install_redis_client" {
  name            = var.ecs_command_config.name
  description     = var.ecs_command_config.description
  type            = var.ecs_command_config.type
  command_content = var.custom_redis_install_script != null ? var.custom_redis_install_script : base64encode(local.default_redis_install_script)
  timeout         = var.ecs_command_config.timeout
  working_dir     = var.ecs_command_config.working_dir
}

# Execute ECS command
resource "alicloud_ecs_invocation" "install_redis_client" {
  instance_id = [alicloud_instance.ecs_instance.id]
  command_id  = alicloud_ecs_command.install_redis_client.id
  depends_on  = [alicloud_kvstore_instance.redis]

  timeouts {
    create = var.ecs_invocation_config.timeout_create
  }
}