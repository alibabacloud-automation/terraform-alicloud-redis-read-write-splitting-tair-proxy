output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.read_write_splitting_through_tair_proxy.vpc_id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = module.read_write_splitting_through_tair_proxy.vswitch_id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = module.read_write_splitting_through_tair_proxy.security_group_id
}

output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = module.read_write_splitting_through_tair_proxy.ecs_instance_id
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = module.read_write_splitting_through_tair_proxy.ecs_instance_public_ip
}

output "ecs_login_address" {
  description = "The login address for ECS instance via workbench"
  value       = module.read_write_splitting_through_tair_proxy.ecs_login_address
}

output "redis_instance_id" {
  description = "The ID of the Redis (Tair) instance"
  value       = module.read_write_splitting_through_tair_proxy.redis_instance_id
}

output "redis_connection_address" {
  description = "The connection address of the Redis (Tair) instance"
  value       = module.read_write_splitting_through_tair_proxy.redis_connection_address
}