#!/usr/bin/env bash

set -e

INPUT=$(tee)

# Get bin_dir to be able to use jq
BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v jq 1> /dev/null 2> /dev/null; then
  echo "jq cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi


export KUBE_CONFIG=$(echo "${INPUT}" | jq -r '.config_file_path')
APPS_ISSUER_CA=$(echo "${INPUT}" | jq -r '.apps_issuer_ca_file')
APPS_CERT=$(echo "${INPUT}" | jq -r '.apps_cert_file')
APPS_KEY=$(echo "${INPUT}" | jq -r '.apps_key_file')
API_CERT=$(echo "${INPUT}" | jq -r '.api_cert_file')
API_KEY=$(echo "${INPUT}" | jq -r '.api_key_file')
API_FQDN=$(echo "${INPUT}" | jq -r '.api_fqdn')


# Step 1
# Replace default ingress certificate. Docs: https://docs.openshift.com/container-platform/4.9/security/certificates/replacing-default-ingress-certificate.html

# Create a config map that includes only the root CA certificate used to sign the wildcard certificate
oc create configmap custom-ca \
    --from-file=ca-bundle.crt=$APPS_ISSUER_CA \
    -n openshift-config

# Update the cluster-wide proxy configuration with the newly created config map
oc patch proxy/cluster \
    --type=merge \
    --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'

# Create a secret that contains the wildcard certificate chain and key
oc create secret tls default-ingress-tls \
    --cert=$APPS_CERT \
    --key=$APPS_KEY \
    -n openshift-ingress

# Update the Ingress Controller configuration with the newly created secret
oc patch ingresscontroller.operator default \
    --type=merge -p \
    '{"spec":{"defaultCertificate": {"name": "default-ingress-tls"}}}' \
    -n openshift-ingress-operator

# Step 2
# Replace API server certificate. Docs: https://docs.openshift.com/container-platform/4.9/security/certificates/api-server.html

# Create a secret that contains the certificate chain and private key in the openshift-config namespace
oc create secret tls api-server-tls \
    --cert=$API_CERT \
    --key=$API_KEY \
    -n openshift-config

# Update the API server to reference the created secret
oc patch apiserver cluster \
    --type=merge -p \
    "{\"spec\":{\"servingCerts\": {\"namedCertificates\":
    [{\"names\": ["${API_FQDN}"], 
    \"servingCertificate\": {\"name\": \"api-server-tls\"}}]}}}"
