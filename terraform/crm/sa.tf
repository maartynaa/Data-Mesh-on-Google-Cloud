resource "google_service_account" "crm_sa" {
  account_id   = "crm-sa"
  display_name = "CRM Service Account"
  description  = "Service account for CRM data domain (Data Mesh)"
}