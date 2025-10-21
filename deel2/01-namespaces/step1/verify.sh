#!/bin/bash

# Controleer of de gebruiker het kubectl get namespaces commando heeft uitgevoerd
# We controleren of ze de namespaces kunnen zien door te testen of ze bestaan

# Controleer of de custom namespaces bestaan
namespaces=("webapp" "database" "monitoring" "development" "production")

for ns in "${namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
        echo "Namespace $ns niet gevonden. Zorg ervoor dat je 'kubectl get namespaces' hebt uitgevoerd."
        exit 1
    fi
done

# Controleer of standaard namespaces bestaan
default_namespaces=("default" "kube-system" "kube-public")

for ns in "${default_namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
        echo "Standaard namespace $ns niet gevonden."
        exit 1
    fi
done

echo "Goed gedaan! Je hebt succesvol de namespaces bekeken."
exit 0