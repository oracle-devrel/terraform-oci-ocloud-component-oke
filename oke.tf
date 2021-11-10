# builds an OKE cluster along with a subnet for the cluster and API endpoint and another subnet for the worker nodes

/*
variable "kubernetes_version"   { default = "v1.20.8" }
variable "node_pool_os" 	{ default = "Oracle Linux" }
variable "node_pool_os_version" { default = "7.9"}
variable "node_pool_shape"      { default = "VM.Standard2.1" }
*/

data "oci_core_images" "node_pool_image" {
  compartment_id           = local.appdev_compartment_ocid
  operating_system         = var.node_pool_os
  operating_system_version = var.node_pool_os_version
  shape			   = var.node_pool_shape
  sort_by		   = "TIMECREATED"
  sort_order		   = "DESC"
}

resource "oci_core_security_list" "okenet_security_list" {
  compartment_id = local.nw_compartment_ocid
  display_name   = "${local.service}_1_oke_securitylist"
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
      max = 6443
      min = 6443
    }
    description = "External access to Kubernetes API endpoint"
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 12250
      min = 12250
    }
    description = "Kubernetes worker to control plane communication"
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    source      = cidrsubnet(local.vcn_cidr, 4, 3)
    protocol   = "all"
    description = "Allow pods on one worker node to communicate with pods on other worker nodes and the K8S controller."
  }

  ingress_security_rules {
    source      = cidrsubnet(local.vcn_cidr, 4, 4)
    protocol   = "all"
    description = "Allow inbound communication from load balancer subnet."
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

resource "oci_core_security_list" "oke_lb_security_list" {
  compartment_id = local.nw_compartment_ocid
  display_name   = "${local.service}_0-oke-lb-securitylist"
  vcn_id         = local.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
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


resource "oci_core_route_table" "okeroutetable" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${local.service}_1_oke_routetable"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = local.igw_id
  }
}

resource "oci_core_route_table" "okenodepoolroutetable" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${local.service}_1_oke_nodepool_routetable"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = local.ngw_id
  }
}

resource "oci_core_route_table" "okelbroutetable" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${local.service}_1_oke_lb_routetable"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = local.igw_id
  }
}

resource "oci_core_subnet" "okenet" {
  cidr_block       = cidrsubnet(local.vcn_cidr, 4, 3)
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_1_oke_cluster_subnet"
  dns_label        = "oke"
  security_list_ids = [oci_core_security_list.okenet_security_list.id]
  route_table_id      = oci_core_route_table.okeroutetable.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "okelbnet" {
  cidr_block       = cidrsubnet(local.vcn_cidr, 4, 4)
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_1_oke_loadbalancer_subnet"
  dns_label        = "okelbnet"
  security_list_ids = [oci_core_security_list.oke_lb_security_list.id]
  route_table_id      = oci_core_route_table.okelbroutetable.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "okenodepoolnet" {
  cidr_block       = cidrsubnet(local.vcn_cidr, 4, 5)
  compartment_id   = local.nw_compartment_ocid
  vcn_id           = local.vcn_id
  display_name     = "${local.service}_1_oke_nodepool_subnet"
  dns_label        = "okenodepool"
  security_list_ids = [oci_core_security_list.okenet_security_list.id]
  route_table_id      = oci_core_route_table.okenodepoolroutetable.id
  prohibit_public_ip_on_vnic = true
}


resource "oci_containerengine_cluster" "oke_cluster" {
    compartment_id = local.appdev_compartment_ocid
    kubernetes_version = var.kubernetes_version
    name = "${local.service}_1_oke_cluster"
    vcn_id = local.vcn_id

    endpoint_config {
        is_public_ip_enabled = "true" 
        subnet_id = oci_core_subnet.okenet.id
    }

    options {
        add_ons {
            is_kubernetes_dashboard_enabled = "true" 
            is_tiller_enabled = "true"
        }
        service_lb_subnet_ids = [oci_core_subnet.okelbnet.id] 
    }
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
    cluster_id = oci_containerengine_cluster.oke_cluster.id
    compartment_id = local.appdev_compartment_ocid
    kubernetes_version = var.kubernetes_version 
    name = "${local.service}_1_oke_nodespool"
    node_shape = var.node_pool_shape
    node_image_id = data.oci_core_images.node_pool_image.images[0].id 
   
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] 
            subnet_id           = oci_core_subnet.okenodepoolnet.id 
        }
        size = var.nodes_count
    }
    ssh_public_key = var.ssh_public_key
}

data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
    cluster_id = oci_containerengine_cluster.oke_cluster.id
}

output "oke_cluster_kube_config" {
  value = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
}

output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "oke_node_pool_id" {
  value = oci_containerengine_node_pool.oke_node_pool.id
}

