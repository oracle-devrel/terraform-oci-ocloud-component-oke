# creates the Instance Pool based on the Instance Configuration defined in instanceConfiguration.tf

resource "oci_core_instance_pool" "instance_pool" {
    compartment_id = local.appdev_compartment_ocid
    instance_configuration_id = oci_core_instance_configuration.instance_configuration.id
    placement_configurations {
        availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
        primary_subnet_id = local.subnet_id
        }
    size = "2"

    display_name = "${local.service}_app_instancepool"

    load_balancers {
        #Required
        backend_set_name = oci_load_balancer_backend_set.backend_set.name
        load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
        port = 80
        vnic_selection = "PrimaryVnic"
    }
}
