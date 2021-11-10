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
    organization        = "Demo"
    organizational_unit = "FOR TESTING ONLY"
  }

  #1 year validity
  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "oci_load_balancer_certificate" "test_certificate" {
    #Required
    certificate_name = "${local.service}_1_test_ssl_certificate"
    load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id

    #Optional
    private_key = tls_private_key.demo_private_key.private_key_pem
    public_certificate = tls_self_signed_cert.demo_certificate.cert_pem
    lifecycle {
        create_before_destroy = true
    }
}
