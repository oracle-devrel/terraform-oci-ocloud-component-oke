# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# creates a Load Balancer and related sub-resources (listener, backend etc.) that will be placed in front of the instances in the instance pool
# the LB will listen to https, port 443 only (using the key and cert defined in certificat.tf) and will talk to the Instance Pool instances using HTTP, port 80

#Load Balancer
resource "oci_load_balancer_load_balancer" "load_balancer" {
    compartment_id = local.nw_compartment_ocid
    display_name = "${local.service}_app_loadbalancer"
    shape = "100Mbps"
    subnet_ids = [local.web_subnet_id]
}

# LB Listener
resource "oci_load_balancer_listener" "lb_listener" {
    default_backend_set_name = "${oci_load_balancer_backend_set.backend_set.name}"
    load_balancer_id = "${oci_load_balancer_load_balancer.load_balancer.id}"
    name = "${local.service}_app_lb_listener"
    port = "443"
    protocol = "HTTP"
    ssl_configuration {
        certificate_name = oci_load_balancer_certificate.test_certificate.certificate_name
        verify_peer_certificate = false
    }
}

#Backend Set
resource "oci_load_balancer_backend_set" "backend_set" {
    health_checker {
        protocol = "HTTP"
        port = "80"
        url_path = "/"
    }
    load_balancer_id = "${oci_load_balancer_load_balancer.load_balancer.id}"
    name = "${local.service}_app_lb_bs"
    policy = "WEIGHTED_ROUND_ROBIN"
    
    session_persistence_configuration {
      # this is a dummy cookie_name definition. I want to switch off session_persistence at all and the only way I have found in TF is to define a cookie that never gets sent (i.e. no session persistence)
        cookie_name = "NO_SESSION_PERSISTENCE"
    }
    
}

/*
#Add 443 ingress policy to existing LBR network security group
resource "oci_core_network_security_group_security_rule" "https" {
  network_security_group_id = local.lbr_nsg_id

  description = "HTTPS"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
*/


output "instance_pool_load_balancer_public_endpoint_url" {
  value = "https://${oci_load_balancer_load_balancer.load_balancer.ip_address_details[0].ip_address}"
}

output "instance_pool_load_balancer_id" {
  value = "https://${oci_load_balancer_load_balancer.load_balancer.id}"
}


