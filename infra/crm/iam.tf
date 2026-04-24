resource "google_bigquery_dataset_iam_member" "crm_owner" {
  dataset_id = google_bigquery_dataset.crm.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:crm-sa@${var.project_id}.iam.gserviceaccount.com" #W GCP trzeba stworzyć service account Name: crm-sa ID: crm-sa
}


resource "google_bigquery_dataset_iam_member" "sales_access" {
  dataset_id = google_bigquery_dataset.crm.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = var.sales_service_account
}