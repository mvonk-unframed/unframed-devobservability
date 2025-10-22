#!/bin/bash

# Verwachte namespace
expected_namespace="frontend"

# Huidige namespace van de context ophalen
current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')

# Als er geen namespace is ingesteld, gebruikt kubectl 'default'
current_namespace=${current_namespace:-default}

# Controleer of het overeenkomt
if [[ "$current_namespace" == "$expected_namespace" ]]; then
    exit 0
else
    exit 1
fi