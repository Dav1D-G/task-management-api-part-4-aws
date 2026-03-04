name_prefix           = "jenkins-part4"
vpc_cidr              = "10.10.0.0/16"
public_subnet_cidrs   = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs  = ["10.10.11.0/24", "10.10.12.0/24"]
key_pair_name         = "jenkins-part4"
public_key_path       = "../jenkins-part4.pub"
jenkins_instance_type = "t3.micro"
enable_ssm            = true
