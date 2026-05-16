resource "google_bigquery_dataset_iam_member" "crm_owner" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_data_products.dataset_id
  role   = "roles/bigquery.dataOwner"
  member = "serviceAccount:${google_service_account.crm_sa.email}"
}

resource "google_project_iam_member" "transfer_service_agent" {
  project = var.project_id
  role    = "roles/storagetransfer.admin"
  member  = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "wheelie_transfer_reader" {
  bucket = "mm-bigdata-2026-data-mesh-wheelie"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "crm_transfer_writer" {
  bucket = google_storage_bucket.crm_bucket.name

  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}