variable "region" {
  default = "us-west-1"
}

variable "sg" {
  default = ["nginx-sg-1"]
}


variable "subnet" {
  default = "public-subnet"
}

variable "vpc_name" {
  default = "ngnix_main_vpc"
}

variable "fromport" {
  default = ["22", "80"]
}

# variable "tags" {
#   description = "A map of tags to assign to resources"
#   type        = map(string)
#   default     = {
#     instance = "i1", 
#     instance = "i2", 
#     instance = "i3"
#     }
# }

variable "tag_specifications" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {
    instance = "i1", 
    instance = "i2", 
    instance = "i3"
    }
}

variable "instance_names" {
  default = ["one", "two", "three"]
}



variable "asg_tags" {
  type        = list(map(string))
  default     = []
  description = "The created ASG will have these tags applied over the default ones (see main.tf)"
}

variable "instance" {
  default = ["i1", "i2", "i3", "i4"]
}

variable "prefix" {
  default = ["i1", "i2", "i3", "i4"]
}

# variable "extra_tags" {
#   default = [
#     {
#       key                 = "Name"
#       value               = "i1"
#       propagate_at_launch = true
#     },
#     {
#       key                 = "Name"
#       value               = "i2"
#       propagate_at_launch = true
#     },
#   ]
# }

# variable "tags" {
#    type     = map(string)
# default = {
#   "Name" = "val1", 
#   "Name" = "val2"
#   }
# }


# variable "typed_flat_map" {
#   default = {
#     key_1 = "value_1"
#     key_2 = "value_2"
#   }
#   type = map(string)
# }

# variable "custom_tags" {
#   description = "Custom tags to set on the Instances in the ASG"
#   type        = map(string)
#   default = {
#     "Name" = "i2"
#     "Name" = "i1"
#   }
# }