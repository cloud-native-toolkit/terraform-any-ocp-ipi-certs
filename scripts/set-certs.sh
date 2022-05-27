#!/usr/bin/env bash

# Step 1
# Replace default ingress certificate. Docs: https://docs.openshift.com/container-platform/4.9/security/certificates/replacing-default-ingress-certificate.html

# Create a config map that includes only the root CA certificate used to sign the wildcard certificate
${BIN_DIR}/oc create configmap custom-ca \
    --from-file=ca-bundle.crt=${APPS_ISSUER_CA} \
    -n openshift-config 1> /dev/null 2> /dev/null

# Update the cluster-wide proxy configuration with the newly created config map
${BIN_DIR}/oc patch proxy/cluster \
    --type=merge \
    --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}' 1> /dev/null 2> /dev/null

# Create a secret that contains the wildcard certificate chain and key
${BIN_DIR}/oc create secret tls default-ingress-tls \
    --cert=${APPS_CERT} \
    --key=${APPS_KEY} \
    -n openshift-ingress 1> /dev/null 2> /dev/null

# Update the Ingress Controller configuration with the newly created secret
${BIN_DIR}/oc patch ingresscontroller.operator default \
    --type=merge -p \
    '{"spec":{"defaultCertificate": {"name": "default-ingress-tls"}}}' \
    -n openshift-ingress-operator 1> /dev/null 2> /dev/null

# Step 2
# Replace API server certificate. Docs: https://docs.openshift.com/container-platform/4.9/security/certificates/api-server.html

# Create a secret that contains the certificate chain and private key in the openshift-config namespace
${BIN_DIR}/oc create secret tls api-server-tls \
    --cert=${API_CERT} \
    --key=${API_KEY} \
    -n openshift-config 1> /dev/null 2> /dev/null

# Update the API server to reference the created secret
${BIN_DIR}/oc patch apiserver cluster \
    --type=merge -p \
    "{\"spec\":{\"servingCerts\": {\"namedCertificates\":
    [{\"names\": [\"${API_FQDN}\"], 
    \"servingCertificate\": {\"name\": \"api-server-tls\"}}]}}}" 1> /dev/null 2> /dev/null

