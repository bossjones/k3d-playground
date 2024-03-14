#!/usr/bin/env bash

# cp -a config/tls/ca.pem
# base64_cmd := if "{{os()}}" == "macos" { "base64 -w 0 -i cert.pem -o ca.pem" } else { "base64 -b 0 -i cert.pem -o ca.pem" }
# grep_cmd := if "{{os()}}" =~ "macos" { "ggrep" } else { "grep" }


# mkcert -cert-file server-cert.pem -key-file server-key.pem -p12-file p12.pem "*.k8s.localhost" k8s.localhost "*.localhost" ::1 127.0.0.1 localhost 127.0.0.1 "*.internal.localhost" "*.local" 2> /dev/null
