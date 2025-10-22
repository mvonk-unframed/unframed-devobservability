#!/bin/bash

# Controleer of de gebruiker de cluster-brede analyse opdracht correct heeft uitgevoerd

# Controleer of cluster-analysis secret bestaat
if ! kubectl get secret cluster-analysis -n default &> /dev/null; then
    exit 1
fi

# Haal werkelijke waarden op
actual_total_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
actual_nginx_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c nginx || echo "0")
actual_total_services=$(kubectl get services --all-namespaces --no-headers 2>/dev/null | wc -l)

# Haal waarden uit secret op
secret_total_pods=$(kubectl get secret cluster-analysis -n default -o jsonpath='{.data.total-pods}' 2>/dev/null | base64 -d)
secret_nginx_pods=$(kubectl get secret cluster-analysis -n default -o jsonpath='{.data.nginx-pods}' 2>/dev/null | base64 -d)
secret_total_services=$(kubectl get secret cluster-analysis -n default -o jsonpath='{.data.total-services}' 2>/dev/null | base64 -d)

# Valideer tellingen
if [ "$secret_total_pods" != "$actual_total_pods" ]; then
    exit 1
fi

if [ "$secret_nginx_pods" != "$actual_nginx_pods" ]; then
    exit 1
fi

if [ "$secret_total_services" != "$actual_total_services" ]; then
    exit 1
fi

exit 0