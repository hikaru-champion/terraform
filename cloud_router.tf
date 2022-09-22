resource "google_compute_router" "default" {
  name    = "default"
  network = "default"
  region  = "asia-northeast1"
}

resource "google_compute_router_nat" "default" {
  name                               = "default"
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}
