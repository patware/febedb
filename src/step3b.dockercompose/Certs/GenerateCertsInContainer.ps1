Write-Host "Generate a CA for CSR Certificate Signing Request"
Write-Host "   Generate private key for CSR using the RSA algorithm"
Write-Host "      openssl genrsa -out generated/febedb.ca.key.private.pem 4096"
openssl genrsa -out generated/febedb.ca.key.private.pem 4096
Write-Host "   Extract public key"
Write-Host "      openssl rsa -in generated/febedb.ca.key.private.pem -pubout -out generated/febedb.ca.key.public.pem"
openssl rsa -in generated/febedb.ca.key.private.pem -pubout -out generated/febedb.ca.key.public.pem
Write-Host "   Create CSR"
Write-Host "      openssl req -new -x509 -key generated/febedb.ca.key.private.pem -out generated/febedb.ca.cert.pem -days 365 -config febedb.ca.cnf"
openssl req -new -x509 -key generated/febedb.ca.key.private.pem -out generated/febedb.ca.cert.pem -days 365 -config febedb.ca.cnf
Write-Host "   Convert key and certificate into the single .pfx file PKCS#12 format"
Write-Host "      openssl pkcs12 -export -inkey generated/febedb.ca.key.private.pem -in generated/febedb.ca.cert.pem -out generated/febedb.ca.cert.pfx -passout file:generated/Password.txt"
openssl pkcs12 -export -inkey generated/febedb.ca.key.private.pem -in generated/febedb.ca.cert.pem -out generated/febedb.ca.cert.pfx -passout file:generated/Password.txt
Write-Host "   Convert certificate to CRT"
Write-Host "      openssl x509 -in generated/febedb.ca.cert.pem -out generated/febedb.ca.cert.crt"
openssl x509 -in generated/febedb.ca.cert.pem -out generated/febedb.ca.cert.crt


Write-Host "Generate Backend SSL"
Write-Host "   Generate private key"
Write-Host "      openssl genrsa -out generated/febedb.backend.key.private.pem 4096"
openssl genrsa -out generated/febedb.backend.key.private.pem 4096
Write-Host "   Extract public key"
Write-Host "      openssl rsa -in generated/febedb.backend.key.private.pem -pubout -out generated/febedb.backend.key.public.pem"
openssl rsa -in generated/febedb.backend.key.private.pem -pubout -out generated/febedb.backend.key.public.pem
Write-Host "   Create CSR"
Write-Host "      openssl req -new -sha256 -key generated/febedb.backend.key.private.pem -out generated/febedb.backend.csr -config febedb.backend.cnf"
openssl req -new -sha256 -key generated/febedb.backend.key.private.pem -out generated/febedb.backend.csr -config febedb.backend.cnf
Write-Host "   Convert CSR to CER"
Write-Host "      openssl x509 -req -in generated/febedb.backend.csr -CA generated/febedb.ca.cert.pem -CAkey generated/febedb.ca.key.private.pem -CAcreateserial -out generated/febedb.backend.cer -days 365 -sha256 -extfile febedb.backend.cnf -extensions req_v3"
openssl x509 -req -in generated/febedb.backend.csr -CA generated/febedb.ca.cert.pem -CAkey generated/febedb.ca.key.private.pem -CAcreateserial -out generated/febedb.backend.cer -days 365 -sha256 -extfile febedb.backend.cnf -extensions req_v3
Write-Host "   convert CER to pfx"
openssl pkcs12 -export -inkey generated/febedb.backend.key.private.pem -in generated/febedb.backend.cer -out generated/febedb.backend.pfx -passout file:generated/Password.txt
Write-Host "      openssl pkcs12 -export -inkey generated/febedb.backend.key.private.pem -in generated/febedb.backend.cer -out generated/febedb.backend.pfx -passout file:generated/Password.txt"

Write-Host "Generate Frontend SSL"
Write-Host "   Generate private key"
Write-Host "      openssl genrsa -out generated/febedb.frontend.key.private.pem 4096"
openssl genrsa -out generated/febedb.frontend.key.private.pem 4096
Write-Host "   Extract public key"
Write-Host "      openssl rsa -in generated/febedb.frontend.key.private.pem -pubout -out generated/febedb.frontend.key.public.pem"
openssl rsa -in generated/febedb.frontend.key.private.pem -pubout -out generated/febedb.frontend.key.public.pem
Write-Host "   Create CSR"
Write-Host "      openssl req -new -sha256 -key generated/febedb.frontend.key.private.pem -out generated/febedb.frontend.csr -config febedb.frontend.cnf"
openssl req -new -sha256 -key generated/febedb.frontend.key.private.pem -out generated/febedb.frontend.csr -config febedb.frontend.cnf
Write-Host "   Convert CSR to CER"
Write-Host "      openssl x509 -req -in generated/febedb.frontend.csr -CA generated/febedb.ca.cert.pem -CAkey generated/febedb.ca.key.private.pem -CAcreateserial -out generated/febedb.frontend.cer -days 365 -sha256 -extfile febedb.frontend.cnf -extensions req_v3"
openssl x509 -req -in generated/febedb.frontend.csr -CA generated/febedb.ca.cert.pem -CAkey generated/febedb.ca.key.private.pem -CAcreateserial -out generated/febedb.frontend.cer -days 365 -sha256 -extfile febedb.frontend.cnf -extensions req_v3
Write-Host "   Convert CER to PFX"
Write-Host "      openssl pkcs12 -export -inkey generated/febedb.frontend.key.private.pem -in generated/febedb.frontend.cer -out generated/febedb.frontend.pfx -passout file:generated/Password.txt"
openssl pkcs12 -export -inkey generated/febedb.frontend.key.private.pem -in generated/febedb.frontend.cer -out generated/febedb.frontend.pfx -passout file:generated/Password.txt
Write-Host "and that\'s a wrap. Check the Certs/Generated folder for the generated files."
