# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# creates the Instance Pool based on the Instance Configuration defined in instanceConfiguration.tf

resource "oci_core_instance_pool" "instance_pool" {
    compartment_id = local.appdev_compartment_ocid
    instance_configuration_id = oci_core_instance_configuration.instance_configuration.id
    placement_configurations {
        availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
        primary_subnet_id = local.subnet_id
        }
    size = var.pool_instance_count

    display_name = "${local.service}_app_instancepool"

    load_balancers {
        backend_set_name = oci_load_balancer_backend_set.backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
        port = 80
        vnic_selection = "PrimaryVnic"
    }
}

output "instance_pool_id" {
  value = oci_core_instance_pool.instance_pool.id
}
