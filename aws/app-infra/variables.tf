variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

variable "container_image" {
  type        = string
  description = "Container image URI used by ECS task definition"
  default     = "nginx:alpine"
}
