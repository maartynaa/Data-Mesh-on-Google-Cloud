resource "google_bigquery_dataset" "egress_crm" {
  dataset_id = "wheelie_crm_shared"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "crm_standard_views" {
  for_each = {for f in var.wheelie_csv_files : f => f}
  
  dataset_id = google_bigquery_dataset.egress_crm.dataset_id
  table_id   = replace(each.key, ".csv", "")
  project    = var.project_id

  view {
    query = "SELECT * FROM `${var.project_id}.wheelie_raw.${replace(each.key, ".csv", "")}`"
    use_legacy_sql = false
  }
}