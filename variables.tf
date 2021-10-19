variable "tenancy_ocid" {
}

variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
    default = ""
}

variable "private_key_path" {
    default = ""
}

variable "region" {
     default = "eu-frankfurt-1"
}

variable "shape" {
    type = string
    description = "Shape of the compute instances"
}

variable "os" {
    type = string
    description = "Compute Instance Operating System without version number"
}

variable "os_version" {
    type = string
    description = "Version of the Compute Instance Operating System"
}

variable "block_storage_size" {
    type = number
    description = "Size of the Block Storage in GBs"
}

variable "cloud_init_parameter_1" {
    type = string
    description = "This is a parameter that will be used when starting the cloud instances. In this example, it is the number of minutes, a 100% CPU usage should be simulated in Instance Pool instances to demonstrate auto-scaling-out."
}

variable "ssh_public_key" {
}


variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "InstanceBootStrap" {
  default = "./userdata/instance"
}

variable "AD" {
  default = "1"
}

variable "appdev_compartment_ocid" {
    type = string
    description = "The OCID of the compartment for the app stack resources"
    default = ""
}

variable "organization" {
  description = "Common Label Part used with all related resources"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}

variable "project" {
  description = "Common Label Part used with all related resources"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}

# Required
# Network compartment which contains all network resources as VCN, database subnet and database network 
# security groups
variable "nw_compartment_ocid" {
    type = string
    description = "The OCID of the compartment for the networking resources"
}

# Required
# VCN
variable "vcn_id" {
    type = string
}


