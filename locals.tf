# copy the discovered resources from datasource.tf into local variables

locals {
  home_region      = "eu-frankfurt-1"
  service          = lower("${var.organization}_${var.project}")
  # vcn_id           = try(data.oci_core_vcns.vcns.virtual_networks[0].id,var.vcn_id)
  # vcn_cidr         = try(data.oci_core_vcns.vcns.virtual_networks[0].cidr_blocks[0],var.vcn_cidr)
  # nw_compartment_ocid = try(data.oci_identity_compartments.nw_compartments.compartments[0].id,var.nw_compartment_ocid)
  # appdev_compartment_ocid = try(data.oci_identity_compartments.appdev_compartments.compartments[0].id,var.appdev_compartment_ocid)
  vcn_id           = var.vcn_id
  vcn_cidr         = data.oci_core_vcn.vcn.cidr_blocks[0]
  nw_compartment_ocid = var.nw_compartment_id
  appdev_compartment_ocid = var.appdev_compartment_id
  subnet_id        = data.oci_core_subnets.app_subnets.subnets[0].id
  nsg_id           = data.oci_core_network_security_groups.app_nsgs.network_security_groups[0].id 
  igw_id           = data.oci_core_internet_gateways.igws.gateways[0].id
  ngw_id           = data.oci_core_nat_gateways.ngws.nat_gateways[0].id
  web_subnet_id        = data.oci_core_subnets.pres_subnets.subnets[0].id
  web_subnet_cidr_block = data.oci_core_subnets.pres_subnets.subnets[0].cidr_block
  lbr_nsg_id           = data.oci_core_network_security_groups.lbr_nsgs.network_security_groups[0].id 
}

