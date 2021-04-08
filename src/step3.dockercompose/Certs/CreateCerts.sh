#!/bin/bash

echo 1. Generate a CA for CSR Certificate Signing Request
echo 1.1 Generate private key for CSR using the RSA algorithm
openssl genrsa -out Generated/febedb.ca.key.private.pem 4096
echo 1.2 Extract public key
openssl rsa -in Generated/febedb.ca.key.private.pem -pubout -out Generated/febedb.ca.key.public.pem
echo 1.3 Create CSR
openssl req -new -x509 -key Generated/febedb.ca.key.private.pem -out Generated/febedb.ca.cert.pem -days 365 -config febedb.ca.cnf
echo 1.4 Convert key and certificate into the single .pfx file PKCS#12 format
openssl pkcs12 -export -inkey Generated/febedb.ca.key.private.pem -in Generated/febedb.ca.cert.pem -out Generated/febedb.ca.cert.pfx -passout file:Generated/Password.txt
echo 1.5 Convert certificate to CRT
openssl x509 -in Generated/febedb.ca.cert.pem -out Generated/febedb.ca.cert.crt

echo 2. Generate Backend SSL
echo 2.1 Generate private key
openssl genrsa -out Generated/febedb.backend.key.private.pem 4096
echo 2.2 Extract public key
openssl rsa -in Generated/febedb.backend.key.private.pem -pubout -out Generated/febedb.backend.key.public.pem
echo 2.3 Create CSR
openssl req -new -sha256 -key Generated/febedb.backend.key.private.pem -out Generated/febedb.backend.csr -config febedb.backend.cnf
echo 2.4 Convert CSR to CER
openssl x509 -req -in Generated/febedb.backend.csr -CA Generated/febedb.ca.cert.pem -CAkey Generated/febedb.ca.key.private.pem -CAcreateserial -out Generated/febedb.backend.cer -days 365 -sha256 -extfile febedb.backend.cnf -extensions req_v3
echo 2.5 convert CER to pfx
openssl pkcs12 -export -inkey Generated/febedb.backend.key.private.pem -in Generated/febedb.backend.cer -out Generated/febedb.backend.pfx -passout file:Generated/Password.txt

echo 3. Generate Frontend SSL
echo 3.1 Generate private key
openssl genrsa -out Generated/febedb.frontend.key.private.pem 4096
echo 3.2 Extract public key
openssl rsa -in Generated/febedb.frontend.key.private.pem -pubout -out Generated/febedb.frontend.key.public.pem
echo 3.3 Create CSR
openssl req -new -sha256 -key Generated/febedb.frontend.key.private.pem -out Generated/febedb.frontend.csr -config febedb.frontend.cnf
echo 3.4 Convert CSR to CER
openssl x509 -req -in Generated/febedb.frontend.csr -CA Generated/febedb.ca.cert.pem -CAkey Generated/febedb.ca.key.private.pem -CAcreateserial -out Generated/febedb.frontend.cer -days 365 -sha256 -extfile febedb.frontend.cnf -extensions req_v3
echo 3.5 Convert CER to PFX
openssl pkcs12 -export -inkey Generated/febedb.frontend.key.private.pem -in Generated/febedb.frontend.cer -out Generated/febedb.frontend.pfx -passout file:Generated/Password.txt
echo and that\'s a wrap. Check the Certs/Generated folder for the generated files.