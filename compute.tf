# creates a Linux 7.9 instance as a blueprint for the instance pool
# the first data element looks up all available images, the newest one is returned as the first element of the array, so we can index it with [0]

# due to the service limits, no dedicated VM host can be deployed in our tenant. However, I left the definition for instances on a Dedicated VM Host here at the bottom (commented out).

variable "compute_os" 	{ default = "Oracle Linux" }
variable "compute_os_version" { default = "7.9"}

data "oci_core_images" "compute_image" {
  compartment_id           = local.appdev_compartment_ocid
  operating_system         = var.compute_os
  operating_system_version = var.compute_os_version
  shape			   = var.InstanceShape
  sort_by		   = "TIMECREATED"
  sort_order		   = "DESC"
}


resource "oci_core_instance" "DemoInstance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = local.appdev_compartment_ocid
  display_name        = "${var.service}_1_app_instancepool_blueprint_instance"
  image               = data.oci_core_images.compute_image.images[0].id 
  shape               = var.InstanceShape
  subnet_id           = local.subnet_id
  
  create_vnic_details {
    #nsg_ids = [local.nsg_id]
    assign_public_ip = false
  }
  #dedicated_vm_host_id = oci_core_dedicated_vm_host.test_dedicated_vm_host.id

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    cpu_100percent_time = var.cpu_100percent_time
    user_data           = base64encode(file(var.InstanceBootStrap))
  }
}

#resource "oci_core_instance" "DedicatedHostVMs" {
#  count               = 4
#  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
#  compartment_id      = local.appdev_compartment_ocid
#  display_name        = "VM #${count.index + 1} on the Dedicated VM Host"
#  image               = var.CustomImage
#  shape               = var.InstanceShape
#  subnet_id           = oci_core_subnet.computenet.id
#  dedicated_vm_host_id = oci_core_dedicated_vm_host.test_dedicated_vm_host.id

#  metadata = {
#    ssh_authorized_keys = var.ssh_public_key
#    user_data           = base64encode(file(var.InstanceBootStrap))
#  }
#}


