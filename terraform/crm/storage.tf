resource "google_storage_bucket" "crm_bucket" {
  name     = "${var.project_id}-crm-data"
  location = var.region

  storage_class = var.storage_class

  uniform_bucket_level_access = true

  labels = {
    domain = "crm"
    layer  = "curated"
  }
}