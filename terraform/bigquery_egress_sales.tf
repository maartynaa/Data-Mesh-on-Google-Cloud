resource "google_bigquery_dataset" "egress_sales" {
  dataset_id = "wheelie_sales_shared"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "sales_standard_views" {
  for_each = {for f in var.wheelie_csv_files : f => f if f != "customer.csv"}
  
  dataset_id = google_bigquery_dataset.egress_sales.dataset_id
  table_id   = replace(each.key, ".csv", "")
  project    = var.project_id

  view {
    query = "SELECT * FROM `${var.project_id}.wheelie_raw.${replace(each.key, ".csv", "")}`"
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "sales_customer_view" {
  dataset_id = google_bigquery_dataset.egress_sales.dataset_id
  table_id   = "customer"
  project    = var.project_id

  view {
    query = <<EOF
      SELECT 
        customer_id,
        SHA256(first_name) as first_name_hash,
        SHA256(last_name) as last_name_hash,
        SHA256(email) as email_hash, 
        address_id, 
        birth_date,
        create_date,
        last_update
      FROM `${var.project_id}.wheelie_raw.customer`
EOF
    use_legacy_sql = false
  }
}
