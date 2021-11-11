# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# builds an OKE cluster along with a subnet for the cluster and API endpoint and another subnet for the worker nodes

# look up the appropriate compute image for the desired shape, operating system and version. The newest one appears in element 0 of the returned data set.
data "oci_core_images" "node_pool_image" {
  compartment_id           = local.appdev_compartment_ocid
  operating_system         = var.node_pool_os
  operating_system_version = var.node_pool_os_version
  shape			   = var.node_pool_shape
  sort_by		   = "TIMECREATED"
  sort_order		   = "DESC"
}

# build the cluster
resource "oci_containerengine_cluster" "oke_cluster" {
    compartment_id = local.appdev_compartment_ocid
    kubernetes_version = var.kubernetes_version
    name = "${local.service}_oke_cluster"
    vcn_id = local.vcn_id

    endpoint_config {
        is_public_ip_enabled = "true" 
        subnet_id = oci_core_subnet.k8s.id
    }

    options {
        add_ons {
            is_kubernetes_dashboard_enabled = "true" 
            is_tiller_enabled = "true"
        }
        service_lb_subnet_ids = [oci_core_subnet.k8slb.id] 
    }
}

#build the pool of worker nodes
resource "oci_containerengine_node_pool" "oke_node_pool" {
    cluster_id = oci_containerengine_cluster.oke_cluster.id
    compartment_id = local.appdev_compartment_ocid
    kubernetes_version = var.kubernetes_version 
    name = "${local.service}_oke_nodespool"
    node_shape = var.node_pool_shape
    node_image_id = data.oci_core_images.node_pool_image.images[0].id 
   
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] 
            subnet_id           = oci_core_subnet.k8snodes.id 
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

