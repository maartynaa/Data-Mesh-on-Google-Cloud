variable "project_id" {
  description = "ID projektu w GCP"
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