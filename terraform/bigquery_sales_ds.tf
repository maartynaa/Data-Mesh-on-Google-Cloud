resource "google_bigquery_dataset" "sales_bigquery_dataset" {
  dataset_id = "sales_ds"
  project    = var.project_id
  location   = var.region
}
