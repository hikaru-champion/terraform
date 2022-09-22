resource "google_compute_instance_template" "default" {
  name_prefix  = "default-"
  machine_type = "f1-micro"
  region       = "asia-northeast1"

  metadata_startup_script = file("./gceme.sh.tpl")

  tags = ["allow-ssh", "allow-service"]
  labels = {
    "key" = "value"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  name   = "default"
  region = "asia-northeast1"
  version {
    instance_template = google_compute_instance_template.default.self_link
  }

  base_instance_name = "mig"
  target_size        = null

  auto_healing_policies {
    health_check      = google_compute_health_check.mig_health_check.self_link
    initial_delay_sec = 30
  }

  timeouts {
    create = "15m"
  }
}

resource "google_compute_region_autoscaler" "default" {
  name   = "default"
  target = google_compute_region_instance_group_manager.default.self_link
  autoscaling_policy {
    max_replicas = 10
    min_replicas = 6
  }
}

resource "google_compute_health_check" "mig_health_check" {
  name = "default"
  http_health_check {
    port = 80
  }
}
