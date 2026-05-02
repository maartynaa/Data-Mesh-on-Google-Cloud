
########################################
# 1. CRM STAGING
########################################

resource "google_bigquery_dataset" "crm_staging" {
  project = var.project_id
  dataset_id = "crm_staging"
  location   = var.region

  description = "CRM staging layer (cleaned source data)"

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
  project = var.project_id
  dataset_id = "crm_intermediate"
  location   = var.region

  description = "CRM intermediate layer (business logic, joins)"

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
  project = var.project_id
  dataset_id = "crm_data_products"
  location   = var.region

  description = "CRM data products (final consumable datasets)"

  labels = {
    domain = "crm"
    layer  = "data_products"
  }

  delete_contents_on_destroy = false
}