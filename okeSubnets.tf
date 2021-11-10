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
  security_list_ids = [oci_core_security_list.k8s_security_list.id]
  route_table_id      = local.pub_subnet_rt_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "k8slb" {
  cidr_block       = lookup(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), "k8slb", "This CIDR is not defined") 
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_k8slb"
  dns_label        = "k8slb"
  security_list_ids = [oci_core_security_list.k8slb_security_list.id]
  route_table_id      = local.pub_subnet_rt_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "k8snodes" {
  cidr_block       = lookup(values(data.terraform_remote_state.external_stack_remote_state.outputs.service_segment_subnets), "k8snodes", "This CIDR is not defined") 
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_k8snodes"
  dns_label        = "k8snodes"
  security_list_ids = [oci_core_security_list.k8snodes_security_list.id]
  route_table_id      = local.priv_subnet_rt_id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_security_list" "k8s_security_list" {
  compartment_id = local.nw_compartment_ocid
  display_name   = "${local.service}_k8s_security_list"
  vcn_id         = local.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 6443
      min = 6443
    }
    description = "External access to Kubernetes API endpoint"
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    tcp_options {
      max = 6443
      min = 6443
    }
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol = "6"
    source   = oci_core_subnet.k8snodes.cidr_block
  }

  ingress_security_rules {
    tcp_options {
      max = 12250
      min = 12250
    }
    description = "Kubernetes worker to control plane communication"
    protocol = "6"
    source   = oci_core_subnet.k8snodes.cidr_block
  }
  

  ingress_security_rules {
    icmp_options {
      type = 3
      code = 4
    }
    description = "Path discovery"
    protocol = 1
    source   = oci_core_subnet.k8snodes.cidr_block
  }

}

resource "oci_core_security_list" "k8slb_security_list" {
  compartment_id = local.nw_compartment_ocid
  display_name   = "${local.service}_k8slb_security_list"
  vcn_id         = local.vcn_id

  dynamic "egress_security_rules" {
    for_each = to_set(var.ports_between_nodepool_subnet_and_k8slb_subnet)
    content {
      protocol    = "6" // tcp
      source      = oci_core_subnet.k8snodes.cidr_block
      stateless   = false
      description = "allow tcp egress on port ${each.key} to worker node subnet"
      
      tcp_options {
        min  = each.key
        max  = each.key
      }
    }
  }

  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    description = "Inbound HTTP communication"
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    description = "Inbound HTTPS communication"
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}
