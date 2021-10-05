# discover all necessary resources that have been deployed prior to applying this stack and which are needed for this stack

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets a list of vNIC attachments on the demo-instance host
data "oci_core_vnic_attachments" "InstanceVnics" {
  compartment_id      = local.appdev_compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  instance_id         = oci_core_instance.DemoInstance.id
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

data "oci_core_vcns" "vcns" {
  compartment_id = local.nw_compartment_ocid
  display_name              = "${local.service}_1_vcn"
  state                     = "AVAILABLE"
}

#data "oci_core_subnets" "app_subnets" {
#  compartment_id = local.nw_compartment_ocid
#  display_name              = "${local.service}-0-app-subnet"
#  state                     = "AVAILABLE"
#}

#data "oci_core_subnets" "web_subnets" {
#  compartment_id = local.nw_compartment_ocid
#  display_name              = "${local.service}-0-web-subnet"
#  state                     = "AVAILABLE"
#}

data "oci_core_network_security_groups" "app_nsgs" {
  compartment_id = local.nw_compartment_ocid
  display_name              = "${local.service}_1_security_group"
}

data "oci_core_network_security_groups" "lbr_nsgs" {
  compartment_id = local.nw_compartment_ocid
  display_name              = "${local.service}_1_security_group"
}

data "oci_core_internet_gateways" "igws" {
  compartment_id = local.nw_compartment_ocid
  display_name              = "${local.service}_1_internet_gateway"
}

data "oci_core_nat_gateways" "ngws" {
  compartment_id = local.nw_compartment_ocid
  display_name              = "${local.service}_1_nat_gateway"
}

