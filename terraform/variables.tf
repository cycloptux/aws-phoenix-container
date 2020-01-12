variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "3"
}

variable "ssh_public_key" {
  description = "Public key material of the generated key pair"
}

variable "instance_type" {
  default     = "t3.small"
  description = "AWS instance type"
}

variable "docdb_cluster_size" {
  description = "Number of servers for the DocumentDB cluster"
  default     = "3"
}

variable "docdb_instance_type" {
  description = "DocumentDB instance type"
  default     = "db.r5.large"
}

variable "docdb_backup_retention" {
  description = "Number of days to retain DocumentDB backups for"
  default     = "30"
}

variable "docdb_password" {
  description = "Master password for the DocumentDB cluster"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "2"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "4"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}

variable "service_desired" {
  description = "Desired numbers of instances in the ecs service"
  default     = "2"
}

variable "admin_cidr_ingress" {
  description = "CIDR to allow tcp/22 ingress to EC2 instance"
}
