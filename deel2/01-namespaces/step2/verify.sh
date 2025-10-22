#!/bin/bash

# Controleer labels op namespaces
webapp_label=$(kubectl get namespace webapp -o jsonpath='{.metadata.labels.purpose}' 2>/dev/null)
database_label=$(kubectl get namespace database -o jsonpath='{.metadata.labels.purpose}' 2>/dev/null)

if [ "$webapp_label" != "frontend" ] || [ "$database_label" != "backend" ]; then
    exit 1
fi

# Controleer ConfigMap
if ! kubectl get configmap namespace-analysis -n default &> /dev/null; then
    exit 1
fi

total_ns=$(kubectl get configmap namespace-analysis -n default -o jsonpath='{.data.total-namespaces}' 2>/dev/null)
custom_ns=$(kubectl get configmap namespace-analysis -n default -o jsonpath='{.data.custom-namespaces}' 2>/dev/null)

if [ -z "$total_ns" ] || [ -z "$custom_ns" ]; then
    exit 1
fi

actual_total=$(kubectl get namespaces --no-headers | wc -l)
if [ "$total_ns" != "$actual_total" ]; then
    exit 1
fi

exit 0