#!/bin/bash

# Controleer of de gebruiker de opdracht correct heeft uitgevoerd
# 1. Controleer of alle verwachte namespaces bestaan
# 2. Controleer of er een namespace is aangemaakt met het juiste aantal

# Controleer of de custom namespaces bestaan
namespaces=("webapp" "database" "monitoring" "development" "production")

for ns in "${namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
        echo "❌ Namespace $ns niet gevonden. Zorg ervoor dat je 'kubectl get namespaces' hebt uitgevoerd."
        exit 1
    fi
done

# Controleer of standaard namespaces bestaan
default_namespaces=("default" "kube-system" "kube-public")

for ns in "${default_namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
        echo "❌ Standaard namespace $ns niet gevonden."
        exit 1
    fi
done

# Tel het totale aantal namespaces
total_namespaces=$(kubectl get namespaces --no-headers | wc -l)
expected_namespace="ns-$total_namespaces"

# Controleer of de cursist een namespace heeft aangemaakt met het juiste aantal
if kubectl get namespace "$expected_namespace" &> /dev/null; then
    echo "✅ Perfect! Je hebt succesvol $total_namespaces namespaces geteld en namespace '$expected_namespace' aangemaakt."
    echo "✅ Je begrijpt nu hoe je namespaces kunt bekijken en beheren."
    exit 0
else
    echo "❌ Namespace '$expected_namespace' niet gevonden."
    echo "💡 Tip: Tel het aantal namespaces met 'kubectl get namespaces' en maak een namespace aan met 'kubectl create namespace ns-<aantal>'"
    echo "📊 Ik zie momenteel $total_namespaces namespaces in het cluster."
    exit 1
fi