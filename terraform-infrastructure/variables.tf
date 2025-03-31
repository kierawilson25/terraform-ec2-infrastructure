# create a block  defining a new instance_name variable 
#name for variables must be unique within the module
variable "instance1_name" {
  description = "value of the name tag for the first EC2 instance"
  type        = string
  default     = "Instance1"
}

variable "instance2_name" {
  description = "value of the name tag for the second EC2 instance"
  type        = string
  default     = "Instance2"
}