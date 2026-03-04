output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = alicloud_vswitch.vswitch.id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = alicloud_security_group.ecs_security_group.id
}

output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = alicloud_instance.ecs_instance.id
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = alicloud_instance.ecs_instance.public_ip
}

output "ecs_login_address" {
  description = "The login address for ECS instance via workbench"
  value       = "https://ecs-workbench.aliyun.com/?from=EcsConsole&instanceType=ecs&regionId=${data.alicloud_regions.current.regions[0].id}&instanceId=${alicloud_instance.ecs_instance.id}"
}

output "redis_instance_id" {
  description = "The ID of the Redis (Tair) instance"
  value       = alicloud_kvstore_instance.redis.id
}

output "redis_connection_domain" {
  description = "The connection domain of the Redis (Tair) instance"
  value       = alicloud_kvstore_instance.redis.connection_domain
}

output "redis_connection_address" {
  description = "The connection address of the Redis (Tair) instance"
  value       = alicloud_kvstore_instance.redis.connection_domain
}

output "ecs_command_id" {
  description = "The ID of the ECS command for Redis client installation"
  value       = alicloud_ecs_command.install_redis_client.id
}

output "ecs_invocation_id" {
  description = "The ID of the ECS command invocation"
  value       = alicloud_ecs_invocation.install_redis_client.id
}