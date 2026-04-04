provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "wheelie_bucket" {
  name          = "${var.project_id}-wheelie"
  project       = var.project_id
  location      = var.region
  storage_class = var.storage_class
  force_destroy = true
}
