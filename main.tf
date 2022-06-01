# provider "kubernetes" {
#   config_path    = "~/.kube/config"
# }

locals {
  certs = "${path.cwd}/${var.cert_dir}"
  apps_issuer_ca_file = "${local.certs}/apps-issuer-ca.crt"
  apps_cert_file = "${local.certs}/apps-cert.crt"
  apps_key_file = "${local.certs}/apps-cert.key"
  api_cert_file = "${local.certs}/api-cert.crt"
  api_key_file = "${local.certs}/api-cert.key"
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

resource "null_resource" "set_certs" {
  depends_on = [
    local_file.apps_issuer_ca,
    local_file.apps_cert,
    local_file.apps_key,
    local_file.api_cert,
    local_file.api_key,
  ]

  provisioner "local-exec" {
    when = create
    command = "${path.module}/scripts/set-certs.sh"

    environment = {
      BIN_DIR = var.bin_dir
      KUBECONFIG = var.config_file_path
      APPS_ISSUER_CA = local.apps_issuer_ca_file
      APPS_CERT = local.apps_cert_file
      APPS_KEY = local.apps_key_file
      API_CERT = local.api_cert_file
      API_KEY = local.api_key_file
      API_FQDN = data.external.oc_login.result.server      
    }   
  }
}
