module "api-certs" {
  depends_on = [
    module.acme-cert-apps,
    module.acme-cert-api,
    module.ocp-ipi
  ]

  source = "./module"

  apps_cert         = module.acme-cert-apps.cert
  apps_key          = module.acme-cert-apps.key
  apps_issuer_ca    = module.acme-cert-apps.issuer_ca
  api_cert          = module.acme-cert-api.cert
  api_key           = module.acme-cert-api.key
  api_issuer_ca     = module.acme-cert-api.issuer_ca
  bin_dir           = module.ocp-ipi.bin_dir
  config_file_path  = module.ocp-ipi.config_file_path
}