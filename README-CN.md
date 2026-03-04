Terraform模块：Redis通过Tair Proxy实现读写分离

# terraform-alicloud-redis-read-write-splitting-tair-proxy

[English](https://github.com/alibabacloud-automation/terraform-alicloud-redis-read-write-splitting-tair-proxy/blob/main/README.md) | 简体中文

Terraform模块，用于在阿里云上实现[Redis通过Tair Proxy实现读写分离](https://www.aliyun.com/solution/tech-solution/read-write-splitting-through-tair-proxy)解决方案。该模块创建完整的基础设施，包括VPC、交换机、安全组、ECS实例以及具有读写分离功能的Redis（Tair）实例。该解决方案能够自动分离读写操作，提高Redis性能和可扩展性。

## 使用方法

使用此模块实现Redis通过Tair Proxy的读写分离：

```terraform
data "alicloud_kvstore_zones" "zones_ids" {
  instance_charge_type = "PostPaid"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_*"
  most_recent = true
  owners      = "system"
}

data "alicloud_instance_types" "default" {
  cpu_core_count       = 4
  system_disk_category = "cloud_essd"
  image_id             = data.alicloud_images.default.images[0].id
  instance_type_family = "ecs.c6"
  availability_zone    = data.alicloud_kvstore_zones.zones_ids.zones[0].id
}

module "redis_read_write_splitting" {
  source = "alibabacloud-automation/redis-read-write-splitting-tair-proxy/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  vswitch_config = {
    cidr_block = "192.168.1.0/24"
    zone_id    = data.alicloud_kvstore_zones.zones_ids.zones[0].id
  }

  kvstore_config = {
    instance_class = "redis.shard.small.2.ce"
    engine_version = "7.0"
    password       = "YourRedisPassword123!"
  }

  instance_config = {
    image_id             = data.alicloud_images.default.images[0].id
    instance_type        = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category = "cloud_essd"
    system_disk_size     = 100
    password             = "YourECSPassword123!"
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-redis-read-write-splitting-tair-proxy/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_ecs_command.install_redis_client](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.install_redis_client](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.ecs_instance](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_kvstore_instance.redis](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/kvstore_instance) | resource |
| [alicloud_security_group.ecs_security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_redis_install_script"></a> [custom\_redis\_install\_script](#input\_custom\_redis\_install\_script) | Custom Redis client installation script. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | The parameters of ECS command for Redis client installation. | <pre>object({<br/>    name        = optional(string, null)<br/>    description = optional(string, "Install Redis client on ECS instance")<br/>    type        = optional(string, "RunShellScript")<br/>    timeout     = optional(number, 600)<br/>    working_dir = optional(string, "/root")<br/>  })</pre> | `{}` | no |
| <a name="input_ecs_invocation_config"></a> [ecs\_invocation\_config](#input\_ecs\_invocation\_config) | The parameters of ECS command invocation. | <pre>object({<br/>    timeout_create = optional(string, "10m")<br/>  })</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | The parameters of ECS instance. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', 'system\_disk\_size' and 'password' are required. | <pre>object({<br/>    instance_name              = optional(string, null)<br/>    system_disk_category       = string<br/>    system_disk_size           = number<br/>    image_id                   = string<br/>    password                   = string<br/>    instance_type              = string<br/>    internet_max_bandwidth_out = optional(number, 5)<br/>  })</pre> | <pre>{<br/>  "image_id": null,<br/>  "instance_type": null,<br/>  "password": null,<br/>  "system_disk_category": null,<br/>  "system_disk_size": null<br/>}</pre> | no |
| <a name="input_kvstore_config"></a> [kvstore\_config](#input\_kvstore\_config) | The parameters of Redis (Tair) instance. The attributes 'instance\_class', 'engine\_version' and 'password' are required. | <pre>object({<br/>    db_instance_name = optional(string, "redis")<br/>    instance_class   = string<br/>    engine_version   = string<br/>    password         = string<br/>    payment_type     = optional(string, "PostPaid")<br/>    read_only_count  = optional(number, 1)<br/>    security_ips     = optional(list(string), ["192.168.0.0/16"])<br/>  })</pre> | <pre>{<br/>  "engine_version": null,<br/>  "instance_class": null,<br/>  "password": null<br/>}</pre> | no |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | The parameters of Security Group. | <pre>object({<br/>    security_group_name = optional(string, "SecurityGroup_1")<br/>    security_group_type = optional(string, "normal")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | List of security group rules to create. | <pre>list(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "80/80",<br/>    "type": "ingress"<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    cidr_block = string<br/>    vpc_name   = optional(string, "VPC_HZ")<br/>  })</pre> | <pre>{<br/>  "cidr_block": null<br/>}</pre> | no |
| <a name="input_vswitch_config"></a> [vswitch\_config](#input\_vswitch\_config) | The parameters of VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "vsw_001")<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_command_id"></a> [ecs\_command\_id](#output\_ecs\_command\_id) | The ID of the ECS command for Redis client installation |
| <a name="output_ecs_instance_id"></a> [ecs\_instance\_id](#output\_ecs\_instance\_id) | The ID of the ECS instance |
| <a name="output_ecs_instance_public_ip"></a> [ecs\_instance\_public\_ip](#output\_ecs\_instance\_public\_ip) | The public IP address of the ECS instance |
| <a name="output_ecs_invocation_id"></a> [ecs\_invocation\_id](#output\_ecs\_invocation\_id) | The ID of the ECS command invocation |
| <a name="output_ecs_login_address"></a> [ecs\_login\_address](#output\_ecs\_login\_address) | The login address for ECS instance via workbench |
| <a name="output_redis_connection_address"></a> [redis\_connection\_address](#output\_redis\_connection\_address) | The connection address of the Redis (Tair) instance |
| <a name="output_redis_connection_domain"></a> [redis\_connection\_domain](#output\_redis\_connection\_domain) | The connection domain of the Redis (Tair) instance |
| <a name="output_redis_instance_id"></a> [redis\_instance\_id](#output\_redis\_instance\_id) | The ID of the Redis (Tair) instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the Security Group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_id"></a> [vswitch\_id](#output\_vswitch\_id) | The ID of the VSwitch |
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)