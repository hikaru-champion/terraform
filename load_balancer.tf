resource "google_compute_backend_service" "backend1" {
  name = "backend1"
  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }
  health_checks = [google_compute_health_check.mig_health_check.self_link]
}

resource "google_compute_url_map" "default" {
  name            = "default"
  default_service = google_compute_backend_service.backend1.self_link
}

resource "google_compute_target_https_proxy" "default" {
  name             = "default"
  url_map          = google_compute_url_map.default.self_link
  ssl_certificates = [google_compute_ssl_certificate.example.self_link]
}

resource "google_compute_ssl_certificate" "example" {
  name        = "example"
  private_key = tls_private_key.example.private_key_pem
  certificate = tls_self_signed_cert.example.cert_pem
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  validity_period_hours = 12

  early_renewal_hours = 3

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  dns_names = ["example.com", "example.net"]

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "default"
  target     = google_compute_target_https_proxy.default.self_link
  port_range = "443"
}

output "external_ip" {
  description = "The external IP assigned to the global forwarding rule."
  value       = google_compute_global_forwarding_rule.default.ip_address
}
