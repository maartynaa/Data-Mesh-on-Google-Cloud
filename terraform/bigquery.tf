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

resource "google_bigquery_table" "survey_responses" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm.dataset_id
  table_id   = "survey_responses"

  description = "Post-rental customer satisfaction surveys sent automatically via email link one day after payment."

  labels = {
    domain = "crm"
    source = "survey"
  }

  external_data_configuration {
    autodetect    = false
    source_format = "GOOGLE_SHEETS"
    source_uris   = ["https://docs.google.com/spreadsheets/d/1CPKh8tUKnnMU5yHMadSEpmHz9W6LaqHvRFCqIgVm7oo/edit"]

    google_sheets_options {
      skip_leading_rows = 1  # pomija header
    }
  }

  schema = jsonencode([
    { name = "response_id",      type = "INTEGER",   mode = "REQUIRED" },
    { name = "customer_id",      type = "INTEGER",   mode = "REQUIRED" },
    { name = "rental_id",        type = "INTEGER",   mode = "REQUIRED" },
    { name = "inventory_id",     type = "INTEGER",   mode = "NULLABLE" },
    { name = "staff_id",         type = "INTEGER",   mode = "NULLABLE" },
    { name = "store_id",         type = "INTEGER",   mode = "NULLABLE" },
    { name = "survey_timestamp", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "rating_overall",   type = "INTEGER",   mode = "NULLABLE" },
    { name = "rating_service",   type = "INTEGER",   mode = "NULLABLE" },
    { name = "rating_price",     type = "INTEGER",   mode = "NULLABLE" },
    { name = "rating_vehicle",   type = "INTEGER",   mode = "NULLABLE" },
    { name = "nps_score",        type = "INTEGER",   mode = "NULLABLE" },
    { name = "comment_text",     type = "STRING",    mode = "NULLABLE" },
    { name = "location",         type = "STRING",    mode = "NULLABLE" },
    { name = "device_type",      type = "STRING",    mode = "NULLABLE" }
  ])
}





