variable "region" {
    default = "us-west-1"
}

variable "vpc" {
    default = "ngnix_main_vpc"
}

variable "subnet" {
    default = ["public_subnetA", "public_subnetB"]
}
