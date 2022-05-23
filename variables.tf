variable "cert_dir" {
  type        = string
  description = "Certificate directory"
  default     = "certs"
}

variable "apps_cert" {
  type        = string
  description = "Default ingress certificate"
}

variable "apps_key" {
  type        = string
  description = "Default ingress certificate key"
}

variable "apps_issuer_ca" {
  type        = string
  description = "Default ingress certificate issuer CA"
}

variable "api_cert" {
  type        = string
  description = "API Server certificate"
}

variable "api_key" {
  type        = string
  description = "API Server certificate key"
}

variable "api_issuer_ca" {
  type        = string
  description = "API Server certificate issuer CA"
}

variable "bin_dir" {
  type        = string
  description = "Path to directory where binaries can be found."
}

variable "config_file_path" {
  type        = string
  description = "Path to kube config."
}
