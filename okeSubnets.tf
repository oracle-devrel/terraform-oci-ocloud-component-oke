variable "ports_between_nodepool_subnet_and_k8slb_subnet" {
  type    = list(string)
  default = ["30198", "10256", "31093", "32551", "30517", "80", "443", "30943", "32206", "31866"]
}


resource "oci_core_subnet" "k8s" {
  cidr_block       = lookup(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), "k8s", "This CIDR is not defined") 
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_k8s"
  dns_label        = "k8s"
  security_list_ids = [oci_core_security_list.okenet_security_list.id]
  route_table_id      = local.pub_subnet_rt_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "k8slb" {
  cidr_block       = lookup(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), "k8slb", "This CIDR is not defined") 
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_k8slb"
  dns_label        = "k8slb"
  security_list_ids = [oci_core_security_list.oke_lb_security_list.id]
  route_table_id      = local.pub_subnet_rt_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "k8snodes" {
  cidr_block       = lookup(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), "k8snodes", "This CIDR is not defined") 
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_k8snodes"
  dns_label        = "k8snodes"
  security_list_ids = [oci_core_security_list.okenet_security_list.id]
  route_table_id      = local.priv_subnet_rt_id
  prohibit_public_ip_on_vnic = true
}
