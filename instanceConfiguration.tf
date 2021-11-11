# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# creates an Instance Configuration (as a a prerequisite for an Instance Pool), using the Blueprint instance defined in compute.tf

resource "oci_core_instance_configuration" "instance_configuration" {
    compartment_id = local.appdev_compartment_ocid
    display_name = "${local.service}_app_instance_configuration"
    instance_id = oci_core_instance.demo_instance.id
    instance_details {
        instance_type = "compute"
        launch_details {
            compartment_id = local.appdev_compartment_ocid
            display_name = "Compute Instance"
            create_vnic_details {
                assign_public_ip = false
            }

            shape = var.shape
            
            metadata = {
               ssh_authorized_keys = var.ssh_public_key
               cpu_100percent_time = var.cloud_init_parameter_1
               user_data           = base64encode(file(var.InstanceBootStrap))
            }
            source_details {
                source_type = "image" 
                image_id = data.oci_core_images.compute_image.images[0].id 
            }
       }
   }
}

