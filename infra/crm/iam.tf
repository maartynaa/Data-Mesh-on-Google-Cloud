resource "google_bigquery_dataset_iam_member" "crm_owner" {
  dataset_id = google_bigquery_dataset.crm.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.crm_sa.email}"
}

