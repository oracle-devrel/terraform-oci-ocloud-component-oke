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

variable "cpu_100percent_time" {
     default = "0"
     description = "The number of minutes, a 100% CPU usage should be simulated in Instance Pool instances to demonstrate auto-scaling-out. Enter 0 (zero) if you don't want this simulation."
}
variable "ssh_public_key" {
}

variable "InstanceShape" {
  default = "VM.Standard2.1"
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

variable "service" {
  description = "Common Label used with all related resources"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}
# Required
# Network compartment which contains all network resources as VCN, database subnet and database network 
# security groups
variable "nw_compartment_ocid" {
    type = string
    description = "The OCID of the compartment for the networking resources"
    default = ""
}

# Required
# VCN
variable "vcn_id" {
    type = string
    default = ""
}


