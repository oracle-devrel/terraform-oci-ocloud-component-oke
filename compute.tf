
# the first data element looks up all available images, the newest one is returned as the first element of the array, so we can index it with [0]

# due to the service limits, no dedicated VM host can be deployed in our tenant. However, I left the definition for instances on a Dedicated VM Host here at the bottom (commented out).

data "oci_core_images" "compute_image" {
  compartment_id           = local.appdev_compartment_ocid
  operating_system         = var.os
  operating_system_version = var.os_version
  shape			   = var.shape
  sort_by		   = "TIMECREATED"
  sort_order		   = "DESC"
}


resource "oci_core_instance" "demo_instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = local.appdev_compartment_ocid
  display_name        = "${local.service}_1_app_demo_instance"
  image               = data.oci_core_images.compute_image.images[0].id 
  shape               = var.shape
  subnet_id           = local.subnet_id
  
  create_vnic_details {
    #nsg_ids = [local.nsg_id]
    assign_public_ip = false
  }
  #dedicated_vm_host_id = oci_core_dedicated_vm_host.test_dedicated_vm_host.id

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    cpu_100percent_time = var.cloud_init_parameter_1
    user_data           = base64encode(file(var.InstanceBootStrap))
  }
}

# --- Volume ---
resource "oci_core_volume" "instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = local.appdev_compartment_ocid
  service_name        = "${local.service}_1_app_demo_instance_block_storage"
  size_in_gbs         = var.block_storage_size
}

# --- Volume Attachment ---
resource "oci_core_volume_attachment" "instance" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.demo_instance.id
  volume_id       = oci_core_volume.instance.id
  use_chap        = var.host.use_chap
}


#resource "oci_core_instance" "dedicated_host_vms" {
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


