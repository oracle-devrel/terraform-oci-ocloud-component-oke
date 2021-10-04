# not used at this time since required subnets app and web are created by the base stack and are just discovered here and used.

/*
resource "oci_core_security_list" "appsecuritylist" {
  compartment_id = local.nw_compartment_ocid
  display_name   = "${var.service}-0-app-securitylist"
  vcn_id         = local.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    description = "External SSH access"
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    description = "http access"
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 443 
      min = 443
    }
    description = "http access"
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    icmp_options {
      type = 0
    }

    protocol = 1
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    icmp_options {
      type = 3
      code = 4
    }

    protocol = 1
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    icmp_options {
      type = 8
    }

    protocol = 1
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_route_table" "poolroutetable" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${var.service}-0-pool-routetable"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = local.ngw_id
  }
}

resource "oci_core_route_table" "lbroutetable" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${var.service}-0-lb-routetable"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = local.igw_id
  }
}

resource "oci_core_subnet" "poolnet" {
  cidr_block       = cidrsubnet(local.vcn_cidr, 4, 5)
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${var.service}-0-pool-subnet"
  dns_label        = "poolnet"
  security_list_ids = [oci_core_security_list.appsecuritylist.id]
  route_table_id      = oci_core_route_table.poolroutetable.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "lbnet" {
  cidr_block       = cidrsubnet(local.vcn_cidr, 4, 6)
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${var.service}-0-lb-subnet"
  dns_label        = "lbnet"
  security_list_ids = [oci_core_security_list.appsecuritylist.id]
  route_table_id      = oci_core_route_table.lbroutetable.id
  prohibit_public_ip_on_vnic = false
}
*/
