resource "google_bigquery_dataset" "egress_fleet" {
  dataset_id = "wheelie_fleet_shared"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "fleet_standard_views" {
  for_each = {for f in var.fleet_tables : f => f}
  
  dataset_id = google_bigquery_dataset.egress_fleet.dataset_id
  table_id   = each.key
  project    = var.project_id

  view {
    query = "SELECT * FROM `${var.project_id}.wheelie_raw.${each.key}`"
    use_legacy_sql = false
  }
}
