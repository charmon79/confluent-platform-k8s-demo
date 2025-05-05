#!/bin/sh

kubectl create secret tls ca-pair-sslcerts \
  --cert=./ca.pem \
  --key=./ca-key.pem -n confluent
