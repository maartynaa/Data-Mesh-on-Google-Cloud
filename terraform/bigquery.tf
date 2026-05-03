resource "google_bigquery_dataset" "wheelie_bigquery_dataset" {
  dataset_id = "wheelie_data"
  project    = var.project_id
  location   = var.region
  delete_contents_on_destroy = true
}
