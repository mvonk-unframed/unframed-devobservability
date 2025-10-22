#!/bin/bash

# Controleer of de gebruiker de resource inventarisatie opdracht correct heeft uitgevoerd

# Controleer of resource-count secret bestaat
if ! kubectl get secret resource-count -n default &> /dev/null; then
    echo "❌ Secret 'resource-count' niet gevonden in default namespace."
    echo "💡 Tip: Maak een secret aan met resource tellingen uit verschillende namespaces"
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
    echo "❌ Webapp pods telling incorrect. Verwacht: $actual_webapp_pods, Gevonden in secret: $secret_webapp_pods"
    echo "💡 Tip: Tel opnieuw met 'kubectl get pods -n webapp'"
    exit 1
fi

if [ "$secret_database_services" != "$actual_database_services" ]; then
    echo "❌ Database services telling incorrect. Verwacht: $actual_database_services, Gevonden in secret: $secret_database_services"
    echo "💡 Tip: Tel opnieuw met 'kubectl get services -n database'"
    exit 1
fi

if [ "$secret_monitoring_deployments" != "$actual_monitoring_deployments" ]; then
    echo "❌ Monitoring deployments telling incorrect. Verwacht: $actual_monitoring_deployments, Gevonden in secret: $secret_monitoring_deployments"
    echo "💡 Tip: Tel opnieuw met 'kubectl get deployments -n monitoring'"
    exit 1
fi

# Bonus: Controleer namespace-resources ConfigMap (optioneel)
bonus_points=""
if kubectl get configmap namespace-resources -n default &> /dev/null; then
    bonus_points=" + bonus ConfigMap ✨"
fi

echo "✅ Perfect! Je hebt succesvol resources in verschillende namespaces verkend:"
echo "   - Webapp pods: $actual_webapp_pods"
echo "   - Database services: $actual_database_services"
echo "   - Monitoring deployments: $actual_monitoring_deployments"
echo "✅ Je begrijpt nu hoe namespace isolatie werkt en hoe je resources per namespace kunt bekijken$bonus_points"
exit 0