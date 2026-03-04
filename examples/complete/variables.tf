variable "region" {
  description = "The region where to deploy the resources"
  type        = string
  default     = "cn-hangzhou"
}

variable "db_password" {
  description = "The password for Redis (Tair) instance. Length 8-30, must contain uppercase letters, lowercase letters, numbers, special characters three items; special characters include: !@#$%^&*()_+-="
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^[0-9A-Za-z_!@#$%^&*()_+\\-=\\+]+$", var.db_password)) && length(var.db_password) >= 8 && length(var.db_password) <= 30
    error_message = "Password length must be 8-30, must contain three items (uppercase letters, lowercase letters, numbers, special characters !@#$%^&*()_+-=)"
  }
}

variable "ecs_instance_password" {
  description = "The password for ECS instance. Server login password, length 8-30, must contain three items (uppercase letters, lowercase letters, numbers, special characters ()`~!@#$%^&*_-+=|{}[]:;<>,.?/)"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^[a-zA-Z0-9-\\(\\)\\`\\~\\!\\@\\#\\$\\%\\^\\&\\*\\_\\-\\+\\=\\|\\{\\}\\[\\]\\:\\;\\<\\>\\,\\.\\?\\/]*$", var.ecs_instance_password)) && length(var.ecs_instance_password) >= 8 && length(var.ecs_instance_password) <= 30
    error_message = "Password length must be 8-30, must contain three items (uppercase letters, lowercase letters, numbers, special characters ()`~!@#$%^&*_-+=|{}[]:;<>,.?/)"
  }
}