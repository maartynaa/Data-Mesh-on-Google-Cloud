
resource "google_bigquery_dataset_iam_member" "crm_owner" {
  project    = var.project_id
  dataset_id = "crm"
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.crm_sa.email}"
}


resource "google_project_iam_member" "crm_sa_job_user" {
  project = var.project_id
  role = "roles/bigquery.jobUser"
  member = "serviceAccount:${google_service_account.crm_sa.email}"
}


resource "google_bigquery_dataset_iam_member" "crm_dp_readers" {
  for_each   = toset(var.crm_dp_readers)
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_data_products.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${each.value}"
}

resource "google_bigquery_dataset_iam_member" "crm_secure_owner" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_secure.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.crm_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "crm_metadata" {
  for_each = toset([
    google_bigquery_dataset.crm.dataset_id,
    google_bigquery_dataset.crm_data_products.dataset_id,
    google_bigquery_dataset.crm_secure.dataset_id
  ])

  project    = var.project_id
  dataset_id = each.value
  role       = "roles/bigquery.metadataViewer"
  member     = "serviceAccount:${google_service_account.crm_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "crm_dp_writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_data_products.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.crm_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "crm_dp_human_readers" {
  for_each = toset(var.crm_dp_human_readers)
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_data_products.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "user:${each.value}"
}

resource "google_project_iam_member" "crm_dp_human_job_users" {
  for_each = toset(var.crm_dp_human_readers)
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "user:${each.value}"
}








# resource "google_project_iam_member" "transfer_service_agent" {
#   project = var.project_id
#   role    = "roles/storagetransfer.admin"
#   member  = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
# }

# resource "google_storage_bucket_iam_member" "wheelie_transfer_reader" {
#   bucket = "mm-bigdata-2026-data-mesh-wheelie"
#   role   = "roles/storage.objectViewer"
#   member = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
# }

# resource "google_storage_bucket_iam_member" "crm_transfer_writer" {
#   bucket = google_storage_bucket.crm_bucket.name
#   role   = "roles/storage.objectAdmin"
#   member = "serviceAccount:project-${var.project_number}@storage-transfer-service.iam.gserviceaccount.com"
# }



# resource "google_bigquery_dataset_iam_member" "crm_staging_reader" {
#   project    = var.project_id
#   dataset_id = "crm_staging"
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.crm_sa.email}"
# }

# resource "google_bigquery_dataset_iam_member" "crm_intermediate_reader" {
#   project    = var.project_id
#   dataset_id = "crm_intermediate"
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.crm_sa.email}"
# }