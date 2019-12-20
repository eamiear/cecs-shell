#!/bin/bash

read -p "Enter your prefix [ssl]: " KEY

echo "[key] Create server key..."

# openssl genrsa -des3 -out $KEY.key 1024
openssl genrsa -out ssl.key 2048

echo "[csr] Create server certificate signing request..."

SUBJECT="/C=HK/ST=Hongkong/L=Hongkong/O=NASA/OU=DEV/CN=$KEY"

openssl req -new -key $KEY.key -out $KEY.csr -subj $SUBJECT

# echo "Remove password..."

# mv $KEY.key $KEY.origin.key
# openssl rsa -in $KEY.origin.key -out $KEY.key

echo "[ca] Sign SSL certificate..."
openssl req -new -x509 -key $KEY.key -out $KEY.ca.crt -days 3650 -subj $SUBJECT

echo "[crt] Sign SSL certificate..."

openssl x509 -req -days 3650 -in $KEY.csr -CA $KEY.ca.crt -CAkey $KEY.key -CAcreateserial -out $KEY.crt

echo "TODO:"
echo "Copy $KEY.crt to ../ssl/$KEY.crt"
echo "Copy $KEY.key to ../ssl/$KEY.key"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    ssl_certificate     ../ssl/$KEY.crt;"
echo "    ssl_certificate_key ../ssl/$KEY.key;"
echo "}"
