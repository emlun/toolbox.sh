#!/bin/bash
# Create an SSL signing request, copy it to a signing host, sign it and
# download the signed certificate.

FILENAME="device"
KEY_FILE="${FILENAME}.key"
REQUEST_FILE="${FILENAME}.csr"
CERT_FILE="${FILENAME}.crt"

UPLOAD_FILE="tmp/${REQUEST_FILE}"
DOWNLOAD_FILE="tmp/${CERT_FILE}"

CA_HOST=home
CA_HOST_CACERT_FILE="/etc/ssl/public/mimer-root-CA.crt"
CA_HOST_CA_KEY_FILE="/etc/ssl/private/mimer-root-CA.key"

trap 'exit $?' ERR

touch "${KEY_FILE}"
chmod 600 "${KEY_FILE}"

openssl req -newkey rsa:2048 \
  -keyout "${KEY_FILE}" \
  -out "${REQUEST_FILE}" \
  -nodes

scp "${REQUEST_FILE}" "${CA_HOST}:${UPLOAD_FILE}"

ssh -t "${CA_HOST}" sudo openssl x509 -req \
  -in "'${UPLOAD_FILE}'" \
  -CA "'${CA_HOST_CACERT_FILE}'" \
  -CAkey "'${CA_HOST_CA_KEY_FILE}'" \
  -out "'${DOWNLOAD_FILE}'" \
  -days 365

scp "${CA_HOST}":"${DOWNLOAD_FILE}" "${CERT_FILE}"
