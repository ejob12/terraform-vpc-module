variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones for subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}