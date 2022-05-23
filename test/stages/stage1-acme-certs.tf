module "acme-cert-apps" {
  source = "github.com/cloud-native-toolkit/terraform-azure-acme-certificate.git"

  domain = "apps.ipi-certs-test.clusters.azure.ibm-software-everywhere.dev"
  wildcard_domain = true

  acme_registration_email = "noe.samaille@ibm.com"

  resource_group_name = "ocp-ipi-rg"
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  client_id           = var.client_id
  client_secret       = var.client_secret
}

module "acme-cert-api" {
  source = "github.com/cloud-native-toolkit/terraform-azure-acme-certificate.git"

  domain = "api.ipi-certs-test.clusters.azure.ibm-software-everywhere.dev"
  wildcard_domain = false

  acme_registration_email = "noe.samaille@ibm.com"

  resource_group_name = "ocp-ipi-rg"
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  client_id           = var.client_id
  client_secret       = var.client_secret
}
