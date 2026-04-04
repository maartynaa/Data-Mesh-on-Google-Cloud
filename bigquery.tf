resource "google_bigquery_dataset" "wheelie_bigquery_dataset" {
  dataset_id = "wheelie_data"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "wheelie_bigquery" {
  for_each = { for f in var.wheelie_csv_files : f => f }

  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  table_id   = replace(each.key, ".csv", "")
  project    = var.project_id

  external_data_configuration {
    source_format = "CSV"
    source_uris   = ["gs://${google_storage_bucket.wheelie_bucket.name}/${each.key}"]

    csv_options {
      skip_leading_rows = 1
      field_delimiter   = ","
      quote             = ""
    }

    autodetect = true
  }
}