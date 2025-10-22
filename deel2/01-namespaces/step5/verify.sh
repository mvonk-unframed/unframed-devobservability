#!/bin/bash

# Controleer of de gebruiker de cluster-brede analyse opdracht correct heeft uitgevoerd

# Controleer of cluster-analysis secret bestaat
if ! kubectl get secret cluster-analysis -n default &> /dev/null; then
    echo "❌ Secret 'cluster-analysis' niet gevonden in default namespace."
    echo "💡 Tip: Maak een secret aan met cluster-brede resource tellingen"
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
    echo "❌ Total pods telling incorrect. Verwacht: $actual_total_pods, Gevonden: $secret_total_pods"
    echo "💡 Tip: Tel opnieuw met 'kubectl get pods --all-namespaces'"
    exit 1
fi

if [ "$secret_nginx_pods" != "$actual_nginx_pods" ]; then
    echo "❌ Nginx pods telling incorrect. Verwacht: $actual_nginx_pods, Gevonden: $secret_nginx_pods"
    echo "💡 Tip: Tel opnieuw met 'kubectl get pods --all-namespaces | grep nginx'"
    exit 1
fi

if [ "$secret_total_services" != "$actual_total_services" ]; then
    echo "❌ Total services telling incorrect. Verwacht: $actual_total_services, Gevonden: $secret_total_services"
    echo "💡 Tip: Tel opnieuw met 'kubectl get services --all-namespaces'"
    exit 1
fi

# Bonus: Controleer label-search ConfigMap (optioneel)
bonus_points=""
if kubectl get configmap label-search -n default &> /dev/null; then
    frontend_pods=$(kubectl get pods --all-namespaces -l app=frontend --no-headers 2>/dev/null | wc -l)
    secret_frontend_pods=$(kubectl get configmap label-search -n default -o jsonpath='{.data.frontend-pods}' 2>/dev/null)
    if [ "$secret_frontend_pods" = "$frontend_pods" ]; then
        bonus_points=" + bonus label search ✨"
    fi
fi

echo "✅ Fantastisch! Je hebt cluster-brede resource analyse beheerst:"
echo "   - Total pods: $actual_total_pods"
echo "   - Nginx pods: $actual_nginx_pods"
echo "   - Total services: $actual_total_services"
echo "✅ Je kunt nu het volledige cluster monitoren en cross-namespace zoeken$bonus_points"
exit 0