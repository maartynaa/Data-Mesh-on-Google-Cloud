resource "google_storage_bucket" "wheelie_bucket" {
  name          = "${var.project_id}-wheelie"
  project       = var.project_id
  location      = var.region
  storage_class = var.storage_class
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.wheelie_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}