variable "project_id" {
  description = "GCP project ID for CRM domain"
  type        = string
}

variable "region" {
  description = "Region dla zasobów"
  type        = string
  default     = "europe-central2"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "crm_shared_dataset" {
  description = "CRM egress dataset"
  type        = string
  default     = "wheelie_crm_shared"
}

variable "project_number" {
  description = "GCP project number for service accounts"
  type        = string
}