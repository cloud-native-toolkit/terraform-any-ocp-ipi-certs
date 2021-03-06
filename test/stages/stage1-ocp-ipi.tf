module "ocp-ipi" {
  source = "github.com/cloud-native-toolkit/terraform-azure-ocp-ipi.git"

  name_prefix                 = "ipi-certs-test"
  domain_resource_group_name  = "ocp-domain"
  region                      = var.region
  subscription_id             = var.subscription_id
  client_id                   = var.client_id
  client_secret               = var.client_secret
  tenant_id                   = var.tenant_id
  pull_secret                 = var.pull_secret
  base_domain                 = "ocp-azure.ibm-software-everywhere.dev"
  openshift_version           = "4.9.31"
}
