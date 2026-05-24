resource "google_bigquery_dataset" "crm" {
  project    = var.project_id
  dataset_id = "crm"
  location   = var.region

  description = "Unified CRM dataset for dbt models"

  labels = {
    domain = "crm"
  }
}

resource "google_bigquery_dataset" "crm_data_products" {
  project     = var.project_id
  dataset_id  = "crm_data_products"
  location    = var.region

  description = "Exposed CRM data products"
}

resource "google_bigquery_dataset" "crm_secure" {
  project     = var.project_id
  dataset_id  = "crm_secure"
  location    = var.region

  description = "Secure CRM dataset for sensitive customer data (PII, profiles)"

  labels = {
    domain = "crm"
    security = "secure"
  }
}


# resource "google_bigquery_table" "gsheet_customers" {
#   project    = var.project_id
#   dataset_id = google_bigquery_dataset.crm_staging.dataset_id
#   table_id   = "gsheet_customers"

#   external_data_configuration {
#     source_format = "GOOGLE_SHEETS"

#     google_sheets_options {
#       skip_leading_rows = 1
#     }

#     source_uris = [
#       "https://docs.google.com/spreadsheets/d/1CPKh8tUKnnMU5yHMadSEpmHz9W6LaqHvRFCqIgVm7oo/edit"
#     ]

#     autodetect = true
#   }
# }


