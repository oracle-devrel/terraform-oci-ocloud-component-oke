# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# creates a Dedicated VM Host (commented out due to lack of available service limits in common tenants)

/*
resource "oci_core_dedicated_vm_host" "dedicated_vm_host" {
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] 
    compartment_id = local.appdev_compartment_ocid
    dedicated_vm_host_shape = "DVH.Standard2.52"
    display_name = "${local.service}_dedicated_vm_host"
}

output "dedicated_vm_host_id" {
  value = oci_core_dedicated_vm_host.dedicated_vm_host.id
}
*/

