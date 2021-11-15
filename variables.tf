variable "vpc_cidr" {
    type = string
    description = "CIDR Block for the VPC"
    default = "30.0.0.0/16"
}

variable "subnets" {
    type = string
    description = "Public Subnet"
    default = "30.0.1.0/24"
}