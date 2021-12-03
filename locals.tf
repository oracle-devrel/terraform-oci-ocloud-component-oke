# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# copy the discovered resources from datasource.tf into local variables

locals {
  regioncode                = lower([for region in data.oci_identity_regions.all_regions.regions : region.key if region.name == var.my_region][0])
  service                   = lower("${var.organization}_${var.project}")
  vcn_id                    = var.vcn_id
  vcn_cidr                  = data.oci_core_vcn.vcn.cidr_blocks[0]
  nw_compartment_ocid       = var.nw_compartment_id
  appdev_compartment_ocid   = var.appdev_compartment_id
  subnet_id                 = data.oci_core_subnets.app_subnets.subnets[0].id
  subnet_cidr_block         = data.oci_core_subnets.app_subnets.subnets[0].cidr_block
  igw_id                    = data.oci_core_internet_gateways.igws.gateways[0].id
  ngw_id                    = data.oci_core_nat_gateways.ngws.nat_gateways[0].id
  web_subnet_id             = data.oci_core_subnets.pres_subnets.subnets[0].id
  pub_subnet_rt_id          = data.oci_core_route_tables.pub_route_tables.route_tables[0].id
  priv_subnet_rt_id         = data.oci_core_route_tables.priv_route_tables.route_tables[0].id
  k8s_cidr                  = lookup(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets, "k8s", "This CIDR is not defined") 
  k8snodes_cidr             = lookup(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets, "k8snodes", "This CIDR is not defined") 
  k8slb_cidr                = lookup(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets, "k8slb", "This CIDR is not defined")  
}
