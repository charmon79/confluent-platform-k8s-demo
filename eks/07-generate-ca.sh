#!/bin/sh

cd "$(dirname "$(realpath "$0")")"

openssl genrsa -out ./ca-key.pem 2048

openssl req -new -key ./ca-key.pem -x509 \
  -days 1000 \
  -out ./ca.pem \
  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"
