variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "key_pair_name" { type = string }
variable "public_key_path" { type = string }
variable "jenkins_instance_type" { type = string }
variable "enable_ssm" { type = bool }
