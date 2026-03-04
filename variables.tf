variable "vpc_config" {
  description = "The parameters of VPC. The attribute 'cidr_block' is required."
  type = object({
    cidr_block = string
    vpc_name   = optional(string, "VPC_HZ")
  })
  default = {
    cidr_block = null
  }
}

variable "vswitch_config" {
  description = "The parameters of VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  type = object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "vsw_001")
  })
}

variable "security_group_config" {
  description = "The parameters of Security Group."
  type = object({
    security_group_name = optional(string, "SecurityGroup_1")
    security_group_type = optional(string, "normal")
  })
  default = {}
}

variable "security_group_rules" {
  description = "List of security group rules to create."
  type = list(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
  }))
  default = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}

variable "kvstore_config" {
  description = "The parameters of Redis (Tair) instance. The attributes 'instance_class', 'engine_version' and 'password' are required."
  type = object({
    db_instance_name = optional(string, "redis")
    instance_class   = string
    engine_version   = string
    password         = string
    payment_type     = optional(string, "PostPaid")
    read_only_count  = optional(number, 1)
    security_ips     = optional(list(string), ["192.168.0.0/16"])
  })
  default = {
    instance_class = null
    engine_version = null
    password       = null
  }
  sensitive = true
}

variable "instance_config" {
  description = "The parameters of ECS instance. The attributes 'image_id', 'instance_type', 'system_disk_category', 'system_disk_size' and 'password' are required."
  type = object({
    instance_name              = optional(string, null)
    system_disk_category       = string
    system_disk_size           = number
    image_id                   = string
    password                   = string
    instance_type              = string
    internet_max_bandwidth_out = optional(number, 5)
  })
  default = {
    system_disk_category = null
    system_disk_size     = null
    image_id             = null
    password             = null
    instance_type        = null
  }
  sensitive = true
}

variable "ecs_command_config" {
  description = "The parameters of ECS command for Redis client installation."
  type = object({
    name        = optional(string, null)
    description = optional(string, "Install Redis client on ECS instance")
    type        = optional(string, "RunShellScript")
    timeout     = optional(number, 600)
    working_dir = optional(string, "/root")
  })
  default = {}
}

variable "ecs_invocation_config" {
  description = "The parameters of ECS command invocation."
  type = object({
    timeout_create = optional(string, "10m")
  })
  default = {}
}

variable "custom_redis_install_script" {
  description = "Custom Redis client installation script. If not provided, the default script will be used."
  type        = string
  default     = null
}