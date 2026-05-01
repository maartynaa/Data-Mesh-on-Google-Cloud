resource "google_bigquery_dataset" "crm" {
  dataset_id = "crm"
  location   = var.region

  description = "CRM domain dataset (Data Mesh)"

  labels = {
    domain = "crm"
  }

  delete_contents_on_destroy = false
}