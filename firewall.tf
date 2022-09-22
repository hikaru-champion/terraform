resource "google_compute_firewall" "mig_health_check" {
  name    = "health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = [80]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-service"]
}

resource "google_compute_firewall" "default_ssh" {
  name    = "default-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}
