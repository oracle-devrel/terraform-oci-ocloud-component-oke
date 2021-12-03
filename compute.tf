# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# the first data element looks up all available images, the newest one is returned as the first element of the array, so we can index it with [0]
# due to the common service limits, no dedicated VM host can be deployed. However, I left the definition for instances on a Dedicated VM Host here at the bottom (commented out).

data "oci_core_images" "compute_image" {
  compartment_id           = local.appdev_compartment_ocid
  operating_system         = var.os
  operating_system_version = var.os_version
  shape			   = var.shape
  sort_by		   = "TIMECREATED"
  sort_order		   = "DESC"
}


# because the standard security list does only allow egress traffic with the VCN CIDR block as target, but we need full egress access 
# in order to be able to install software on these machines. Furthermore, we will allow ssh ingress traffic for the app subnet's CIDR block, 
# egress to the Oracle Services Network to start the Bastion Host plugin on the instances.
# so we define a network security group, allowing this access and associate it with the compute instances

resource "oci_core_network_security_group" "instances_nsg" {
    compartment_id = local.nw_compartment_ocid 
    vcn_id = local.vcn_id
    display_name = "${local.service}_app_compute_instances_nsg" 
}

# add a rule to allow stateful egress tcp traffic to 0.0.0.0/0 using all ports

resource "oci_core_network_security_group_security_rule" "tcp_egress_to_all" {
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  description               = "tcp egress to all"
  direction                 = "EGRESS"
  protocol                  = 6 //tcp
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "ssh_ingress_from_app_subnet" {
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  description               = "ssh ingress from app subnet"
  direction                 = "INGRESS"
  protocol                  = 6 //tcp
  source_type               = "CIDR_BLOCK"
  source                    = local.subnet_cidr_block  
  tcp_options {
        destination_port_range {
            max = "22"
            min = "22"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "tcp_egress_to_all_osn_services" {
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  description               = "tcp egress to all OSN services"
  direction                 = "EGRESS"
  protocol                  = 6 //tcp
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = "all-${local.regioncode}-services-in-oracle-services-network"
}

resource "oci_core_network_security_group_security_rule" "tcp_egress_to_object_storage" {
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  description               = "tcp egress to object storage"
  direction                 = "EGRESS"
  protocol                  = 6 //tcp
  destination_type          = "SERVICE_CIDR_BLOCK"
  destination               = "oci-${local.regioncode}-objectstorage"
}

resource "oci_core_instance" "demo_instance" {
  depends_on          = [ oci_core_network_security_group_security_rule.tcp_egress_to_all ]
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  compartment_id      = local.appdev_compartment_ocid
  display_name        = "${local.service}_app_demo_instance"
  image               = data.oci_core_images.compute_image.images[0].id 
  shape               = var.shape
  subnet_id           = local.subnet_id
  
  create_vnic_details {
    nsg_ids = [oci_core_network_security_group.instances_nsg.id]
    assign_public_ip = false
  }

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
  display_name        = "${local.service}_app_demo_instance_block_storage"
  size_in_gbs         = var.block_storage_size
}

# --- Volume Attachment ---
resource "oci_core_volume_attachment" "instance" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.demo_instance.id
  volume_id       = oci_core_volume.instance.id
}


#resource "oci_core_instance" "dedicated_host_vms" {
#  count               = 4
#  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
#  compartment_id      = local.appdev_compartment_ocid
#  display_name        = "${local.service}_dedicated_vm_host_instance #${count.index + 1}"
#  image               = data.oci_core_images.compute_image.images[0].id 
#  shape               = var.shape
#  subnet_id           = local.subnet_id
#  dedicated_vm_host_id = oci_core_dedicated_vm_host.dedicated_vm_host.id

#  metadata = {
#    ssh_authorized_keys = var.ssh_public_key
#    cpu_100percent_time = var.cloud_init_parameter_1
#    user_data           = base64encode(file(var.InstanceBootStrap))
#  }
#}

output "compute_instance_id" {
  value = oci_core_instance.demo_instance.id
}

