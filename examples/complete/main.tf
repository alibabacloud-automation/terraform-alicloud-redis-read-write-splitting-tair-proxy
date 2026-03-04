provider "alicloud" {
  region = var.region
}

# Get available zones for KVStore
data "alicloud_kvstore_zones" "zones_ids" {
  instance_charge_type = "PostPaid"
}

# Get available images
data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_*"
  most_recent = true
  owners      = "system"
}

# Get available instance types
data "alicloud_instance_types" "default" {
  image_id             = data.alicloud_images.default.images[0].id
  instance_type_family = "ecs.c9i"
  availability_zone    = data.alicloud_kvstore_zones.zones_ids.zones[length(data.alicloud_kvstore_zones.zones_ids.zones) - 1].id
}

# Generate a random suffix for resource names
resource "random_id" "suffix" {
  byte_length = 8
}

locals {
  common_name = random_id.suffix.hex
}

# Call the module
module "read_write_splitting_through_tair_proxy" {
  source = "../../"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
    vpc_name   = "VPC_HZ"
  }

  vswitch_config = {
    cidr_block   = "192.168.1.0/24"
    zone_id      = data.alicloud_kvstore_zones.zones_ids.zones[length(data.alicloud_kvstore_zones.zones_ids.zones) - 1].id
    vswitch_name = "vsw_001"
  }

  security_group_config = {
    security_group_name = "SecurityGroup_1"
    security_group_type = "normal"
  }

  security_group_rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "192.168.0.0/16"
    }
  ]

  kvstore_config = {
    db_instance_name = "redis"
    instance_class   = "redis.shard.small.2.ce"
    engine_version   = "7.0"
    password         = var.db_password
    payment_type     = "PostPaid"
    read_only_count  = 1
    security_ips     = ["192.168.0.0/16"]
  }

  instance_config = {
    instance_name              = "ecs-${local.common_name}"
    system_disk_category       = "cloud_essd"
    system_disk_size           = 100
    image_id                   = data.alicloud_images.default.images[0].id
    password                   = var.ecs_instance_password
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    internet_max_bandwidth_out = 5
  }

  ecs_command_config = {
    name        = "install-redis-client-${local.common_name}"
    description = "Install Redis client on ECS instance"
    type        = "RunShellScript"
    timeout     = 600
    working_dir = "/root"
  }

  ecs_invocation_config = {
    timeout_create = "10m"
  }
}