resource "google_bigquery_dataset" "wheelie_bigquery_dataset" {
  dataset_id = "wheelie_raw"
  project    = var.project_id
  location   = var.region
}