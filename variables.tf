# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- Oracle Resource Manager configuration ---
variable "tenancy_ocid"     { }
variable "compartment_ocid" { }

// --- User Profile configuration ---
variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
    default = ""
}

variable "private_key_path" {
    default = ""
}

// --- Application Stack variables ---
variable "my_region"  {
    type = string
    description = "Region where this stack should be deployed to"
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

variable "node_pool_shape" {
    type = string
    description = "Shape of the Kubernetes worker nodes"
}

variable "node_pool_os" {
    type = string
    description = "Compute Instance Operating System without version number of the Kubernetes worker nodes"
}

variable "node_pool_os_version" {
    type = string
    description = "Version of the Compute Instance Operating System of the Kubernetes worker nodes"
}

variable "kubernetes_version" {
    type = string
    description = "Version of the Kubernetes cluster"
}

variable "nodes_count" {
    type = string
    description = "Total number of Kubernetes worker nodes"
}

variable "block_storage_size" {
    type = number
    description = "Size of the Block Storage in GBs"
}

variable "cloud_init_parameter_1" {
    type = string
    description = "This is a parameter that will be used when starting the cloud instances. In this example, it is the number of minutes, a 100% CPU usage should be simulated in Instance Pool instances to demonstrate auto-scaling-out."
}

variable "pool_instance_count" {
    type = string
    description = "This is the number of VMs that are created in the Instance Pool."
}

variable "ssh_public_key" {
     type = string
     description = "Public Key of the RSA key pair to authenticate the SSH connection to created instances."
}

variable "InstanceBootStrap" {
  default = "./instancebootstrap.sh"
}

variable "AD" {
  default = "1"
}

variable "stack_id" {
    type = string
    description = "Landing Zone Stack OCID"
}

variable "appdev_compartment_id" {
    type = string
    description = "The OCID of the compartment for the app stack resources"
}

variable "organization" {
  description = "Common Label Part used with all related resources"
  type        = string
}

variable "project" {
  description = "Common Label Part used with all related resources"
  type        = string
}

variable "environment" {
  description = "Common Label used with all related resources"
  type        = string
}

variable "nw_compartment_id" {
    type = string
    description = "The OCID of the compartment for the networking resources"
}

variable "vcn_id" {
    type = string
}
