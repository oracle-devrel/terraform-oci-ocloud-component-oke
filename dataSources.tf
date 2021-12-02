# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# discover all necessary resources that have been deployed prior to applying this stack and which are needed for this stack

data "oci_identity_regions" "all_regions" {
}

# Pull the state file of the existing Resource Manager stack (the network stack) into this context
data "oci_resourcemanager_stack_tf_state" "stack1_tf_state" {
  stack_id   = "${var.stack_id}"
  local_path = "stack1.tfstate"
}

# Load the pulled state file into a remote state data source
data "terraform_remote_state" "external_stack_remote_state" {
  backend = "local"
  config = {
    path = "${data.oci_resourcemanager_stack_tf_state.stack1_tf_state.local_path}"
  }
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets a list of vNIC attachments on the demo-instance host
data "oci_core_vnic_attachments" "InstanceVnics" {
  compartment_id      = local.appdev_compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  instance_id         = oci_core_instance.demo_instance.id
}

# Gets the OCID of the first (default) vNIC on the demo-instance host
data "oci_core_vnic" "InstanceVnic" {
  vnic_id = data.oci_core_vnic_attachments.InstanceVnics.vnic_attachments[0]["vnic_id"]
}

data "oci_identity_compartments" "nw_compartments" {
  compartment_id = var.tenancy_ocid
  name              = "${local.service}_network_compartment"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_identity_compartments" "appdev_compartments" {
  compartment_id = var.tenancy_ocid
  name                      = "${local.service}_application_compartment"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_core_vcn" "vcn" {
  vcn_id     =     var.vcn_id
}

data "oci_core_subnets" "app_subnets" {
  compartment_id            = local.nw_compartment_ocid
  vcn_id                    = var.vcn_id
  display_name              = "${local.service}_app"
  state                     = "AVAILABLE"
}

data "oci_core_subnets" "pres_subnets" {
  compartment_id            = local.nw_compartment_ocid
  vcn_id                    = var.vcn_id
  display_name              = "${local.service}_pres"
  state                     = "AVAILABLE"
}

data "oci_core_internet_gateways" "igws" {
  compartment_id   =     var.nw_compartment_id
  vcn_id           =     var.vcn_id
}

data "oci_core_nat_gateways" "ngws" {
   compartment_id  =     var.nw_compartment_id
   vcn_id          =     var.vcn_id
}

data "oci_core_route_tables" "pub_route_tables" {
    compartment_id = var.nw_compartment_id
    display_name = "${local.service}_${lower(var.environment)}_network_1_pub_rt"
    vcn_id = var.vcn_id
}

data "oci_core_route_tables" "priv_route_tables" {
    compartment_id = var.nw_compartment_id
    display_name = "${local.service}_${lower(var.environment)}_network_1_priv_rt"
    vcn_id = var.vcn_id
}

