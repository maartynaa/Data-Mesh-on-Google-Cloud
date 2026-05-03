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

resource "google_storage_bucket_object" "wheelie_database" {
  for_each = { for f in var.wheelie_csv_files : f => f }

  name   = basename(each.value)  # tylko nazwa pliku
  bucket = google_storage_bucket.wheelie_bucket.name
  source = "../data/${each.value}"
  content_type = "text/csv"
}