#!/bin/sh

# # # Generate self signed root CA cert
# # openssl req -new -x509 -days 3650 -config server_openssl.cnf -keyout ca.key -out ca.crt

# # # Create a private key for the server
# # openssl genrsa -out key.pem 2048

# # copy the ca.pem to ca.crt
# cp -a ca.pem ca.crt

# # Generate server CSR with SAN
# openssl req -new -key key.pem -out server.csr -config server_openssl.cnf

# # Sign the server CSR with CA
# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extfile server_openssl.cnf -extensions v3_req

# # Verify if it's a SAN cert
# # if it's a SAN cert, it should print the SANs
# openssl x509 -in server.crt -text -noout | grep -A1 "Subject Alternative Name"

# # Generate self signed root CA cert
# openssl req -new -x509 -days 3650 -config server_openssl.cnf -keyout ca.key -out ca.crt

# # Create a private key for the server
# openssl genrsa -out server.key 2048

# # Generate server CSR with SAN
# openssl req -new -key server.key -out server.csr -config server_openssl.cnf

# # Sign the server CSR with CA
# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extfile server_openssl.cnf -extensions v3_req

# # Verify if it's a SAN cert
# # if it's a SAN cert, it should print the SANs
# openssl x509 -in server.crt -text -noout | grep -A1 "Subject Alternative Name"

cd config/tls/mysql-kine
# copy root cert to current directory
cp -a /Users/malcolm/Library/Application\ Support/mkcert/*.pem .

mkcert -cert-file cert.pem -key-file key.pem -p12-file p12.pem "kine-db" mysql-kine "*.localhost" ::1 127.0.0.1 localhost 127.0.0.1 192.168.3.13 "*.internal.localhost" "*.local" 2> /dev/null

cd -
