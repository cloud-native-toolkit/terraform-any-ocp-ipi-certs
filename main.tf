locals {
  apps_issuer_ca_file = "${path.module}/apps-issuer-ca.crt"
  apps_cert_file = "${path.module}/apps-cert.crt"
  apps_key_file = "${path.module}/apps-cert.key"
  api_cert_file = "${path.module}/api-cert.crt"
  api_key_file = "${path.module}/api-cert.key"
}

resource local_file apps_issuer_ca {
  content  = var.apps_issuer_ca
  filename = local.apps_issuer_ca_file
}
resource local_file apps_cert {
  content  = var.apps_cert
  filename = local.apps_cert_file
}
resource local_file apps_key {
  content  = var.apps_key
  filename = local.apps_key_file
}
resource local_file api_cert {
  content  = <<EOF
${var.api_cert}
${var.api_issuer_ca}
EOF
  filename = local.api_cert_file
}
resource local_file api_key {
  content  = var.api_key
  filename = local.api_key_file
}

data external "oc_login" {
  program = ["bash", "${path.module}/scripts/oc-login.sh"]

  query = {
    bin_dir = var.bin_dir
    config_file_path = var.config_file_path
  }
}

data external "oc_login" {
  depends_on = [
    local_file.apps_issuer_ca,
    local_file.apps_cert,
    local_file.apps_key,
    local_file.api_cert,
    local_file.api_key,
  ]
  program = ["bash", "${path.module}/scripts/set-certs.sh"]

  query = {
    bin_dir = var.bin_dir
    config_file_path = var.config_file_path
    apps_issuer_ca_file = local.apps_issuer_ca_file
    apps_cert_file = local.apps_cert_file
    apps_key_file = local.apps_key_file
    api_cert_file = local.api_cert_file
    api_key_file = local.api_key_file
    api_fqdn = data.external.oc_login.result.server
  }
}
