locals {
  vm_count = {
    default = 1
    stage = 1
    prod = 2
  }
}

variable "YC_CLOUD_ID" { default = "" }
variable "YC_FOLDER_ID" { default = "" }
variable "YC_ZONE" { default = "" }
