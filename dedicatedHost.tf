# creates a Dedicated VM Host (commented out due to lack of available service limits in our tenant)

/*
resource "oci_core_dedicated_vm_host" "test_dedicated_vm_host" {
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] 
    compartment_id = local.appdev_compartment_ocid
    dedicated_vm_host_shape = "DVH.Standard2.52"
    display_name = "${local.service}_1_app_dedicated_vm_host"
}
*/

