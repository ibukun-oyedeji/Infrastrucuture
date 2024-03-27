variable "env_code" {
  type        = string
  description = "value"
  default     = "assessment"
}

variable "vpc_name" {
  type        = string
  description = "name of the vpc"
  default     = "vpc"
}

variable "vpc_cidr" {
  type        = string
  description = " vpc cidr block "
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  type        = list(any)
  description = "public subnet cidr block "
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  type        = string
  description = "The ec2 instance type to be deployed"
  default     = "t3.micro"
}


