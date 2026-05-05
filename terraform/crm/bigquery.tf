########################################
# 1. CRM STAGING
########################################

resource "google_bigquery_dataset" "crm_staging" {
  project    = var.project_id
  dataset_id = "crm_staging"
  location   = var.region

  description = "CRM staging layer - cleaned source data"

  labels = {
    domain = "crm"
    layer  = "staging"
  }

  delete_contents_on_destroy = false
}

########################################
# 2. CRM INTERMEDIATE
########################################

resource "google_bigquery_dataset" "crm_intermediate" {
  project    = var.project_id
  dataset_id = "crm_intermediate"
  location   = var.region

  description = "CRM intermediate layer - joins and business logic"

  labels = {
    domain = "crm"
    layer  = "intermediate"
  }

  delete_contents_on_destroy = false
}

########################################
# 3. CRM DATA PRODUCTS
########################################

resource "google_bigquery_dataset" "crm_data_products" {
  project    = var.project_id
  dataset_id = "crm_data_products"
  location   = var.region

  description = "CRM data products - final analytical datasets"

  labels = {
    domain = "crm"
    layer  = "data_products"
  }

  delete_contents_on_destroy = false
}



resource "google_bigquery_table" "gsheet_customers" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.crm_staging.dataset_id
  table_id   = "gsheet_customers"

  external_data_configuration {
    source_format = "GOOGLE_SHEETS"

    google_sheets_options {
      skip_leading_rows = 1
    }

    source_uris = [
      "https://docs.google.com/spreadsheets/d/1CPKh8tUKnnMU5yHMadSEpmHz9W6LaqHvRFCqIgVm7oo/edit"
    ]

    autodetect = true
  }
}