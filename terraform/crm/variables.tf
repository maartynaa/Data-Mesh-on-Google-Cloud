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