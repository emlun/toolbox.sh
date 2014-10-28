#!/bin/bash

filename="device"
key_file="${filename}.key"
request_file="${filename}.csr"
cert_file="${filename}.crt"

upload_file="tmp/${request_file}"
download_file="tmp/${cert_file}"

trap 'exit $?' ERR

openssl req -newkey rsa:2048 -keyout "${key_file}" -out "${request_file}" -nodes

scp "${request_file}" "mimer:${upload_file}"

ssh -t mimer sudo openssl x509 -req -in "'${upload_file}'" -CA /etc/ssl/public/mimer-root-CA.crt -CAkey /etc/ssl/private/mimer-root-CA.key -out "'${download_file}'" -days 365

scp "mimer:${download_file}" "${cert_file}"
