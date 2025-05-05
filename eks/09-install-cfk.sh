#!/bin/sh

kubectl create namespace confluent

helm upgrade --install operator confluentinc/confluent-for-kubernetes --namespace confluent
