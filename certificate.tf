# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# creates an TLS private key and self-signed certificate (with a validity of one year)
# for the usage in the load balancer listener and its HTTPS configuration

resource "tls_private_key" "demo_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "demo_certificate" {

  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.demo_private_key.private_key_pem

  subject {
    common_name         = "${local.service}_app_demo_certificate"
    organization        = "Test Demo Org"
    organizational_unit = "THIS CERTIFICATE IS FOR TESTING PURPOSES ONLY"
  }

  #valid for 30 days
  validity_period_hours = 30 * 24

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "oci_load_balancer_certificate" "test_certificate" {
    certificate_name = "${local.service}_1_test_ssl_certificate"
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
    private_key = tls_private_key.demo_private_key.private_key_pem
    public_certificate = tls_self_signed_cert.demo_certificate.cert_pem
    lifecycle {
        create_before_destroy = true
    }
}
