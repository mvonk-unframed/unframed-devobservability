#!/bin/bash

# Controleer of de gebruiker de resource inventarisatie opdracht correct heeft uitgevoerd

# Controleer of resource-count secret bestaat
if ! kubectl get secret resource-count -n default &> /dev/null; then
    exit 1
fi

# Haal de werkelijke resource aantallen op
actual_webapp_pods=$(kubectl get pods -n webapp --no-headers 2>/dev/null | wc -l)
actual_database_services=$(kubectl get services -n database --no-headers 2>/dev/null | wc -l)
actual_monitoring_deployments=$(kubectl get deployments -n monitoring --no-headers 2>/dev/null | wc -l)

# Haal de waarden uit de secret op
secret_webapp_pods=$(kubectl get secret resource-count -n default -o jsonpath='{.data.webapp-pods}' 2>/dev/null | base64 -d)
secret_database_services=$(kubectl get secret resource-count -n default -o jsonpath='{.data.database-services}' 2>/dev/null | base64 -d)
secret_monitoring_deployments=$(kubectl get secret resource-count -n default -o jsonpath='{.data.monitoring-deployments}' 2>/dev/null | base64 -d)

# Valideer de tellingen
if [ "$secret_webapp_pods" != "$actual_webapp_pods" ]; then
    exit 1
fi

if [ "$secret_database_services" != "$actual_database_services" ]; then
    exit 1
fi

if [ "$secret_monitoring_deployments" != "$actual_monitoring_deployments" ]; then
    exit 1
fi

exit 0