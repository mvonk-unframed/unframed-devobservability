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

# Tel het totale aantal namespaces (exclusief de nieuwe namespace die de cursist heeft aangemaakt)
total_namespaces=$(kubectl get namespaces --no-headers | wc -l)

# Zoek naar een namespace die begint met "ns-" (aangemaakt door cursist)
created_namespace=$(kubectl get namespaces --no-headers | grep "^ns-" | head -1 | awk '{print $1}')

if [ -z "$created_namespace" ]; then
    echo "❌ Geen namespace gevonden die begint met 'ns-'."
    echo "💡 Tip: Tel het aantal namespaces met 'kubectl get namespaces' en maak een namespace aan met 'kubectl create namespace ns-<aantal>'"
    echo "📊 Ik zie momenteel $total_namespaces namespaces in het cluster."
    exit 1
fi

# Extraheer het getal uit de namespace naam
namespace_number=$(echo "$created_namespace" | sed 's/ns-//')

# Het verwachte aantal zou 1 minder moeten zijn dan het huidige totaal (omdat de cursist er 1 heeft toegevoegd)
expected_original_count=$((total_namespaces - 1))

if [ "$namespace_number" = "$expected_original_count" ]; then
    echo "✅ Perfect! Je hebt succesvol $expected_original_count namespaces geteld en namespace '$created_namespace' aangemaakt."
    echo "✅ Je begrijpt nu hoe je namespaces kunt bekijken en beheren."
    exit 0
else
    echo "❌ Namespace '$created_namespace' gevonden, maar het getal ($namespace_number) komt niet overeen met het verwachte aantal ($expected_original_count)."
    echo "💡 Tip: Tel het aantal namespaces VOOR je een nieuwe aanmaakt, en gebruik dat getal."
    echo "📊 Ik zie momenteel $total_namespaces namespaces (inclusief jouw nieuwe namespace)."
    exit 1
fi