resource "google_bigquery_dataset_access" "auth_sales_standard" {
  for_each   = google_bigquery_table.sales_standard_views
  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  project    = var.project_id

  view {
    project_id = var.project_id
    dataset_id = each.value.dataset_id
    table_id   = each.value.table_id
  }
}

resource "google_bigquery_dataset_access" "auth_crm_standard" {
  for_each   = google_bigquery_table.crm_standard_views
  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  project    = var.project_id

  view {
    project_id = var.project_id
    dataset_id = each.value.dataset_id
    table_id   = each.value.table_id
  }
}

resource "google_bigquery_dataset_access" "auth_fleet_standard" {
  for_each   = google_bigquery_table.fleet_standard_views
  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  project    = var.project_id

  view {
    project_id = var.project_id
    dataset_id = each.value.dataset_id
    table_id   = each.value.table_id
  }
}

resource "google_bigquery_dataset_access" "auth_sales_customer" {
  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  project    = var.project_id

  view {
    project_id = var.project_id
    dataset_id = google_bigquery_dataset.egress_sales.dataset_id
    table_id   = google_bigquery_table.sales_customer_view.table_id
  }
}

resource "google_bigquery_dataset_access" "auth_fleet_customer" {
  dataset_id = google_bigquery_dataset.wheelie_bigquery_dataset.dataset_id
  project    = var.project_id

  view {
    project_id = var.project_id
    dataset_id = google_bigquery_dataset.egress_fleet.dataset_id
    table_id   = google_bigquery_table.fleet_customer_view.table_id
  }
}
