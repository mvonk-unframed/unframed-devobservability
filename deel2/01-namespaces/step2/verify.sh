#!/bin/bash

# Controleer of de gebruiker de describe commando's heeft uitgevoerd
# We testen dit door te controleren of de namespaces correct bestaan en toegankelijk zijn

# Test of gebruiker namespace details kan bekijken
if ! kubectl describe namespace webapp &> /dev/null; then
    echo "Kon namespace 'webapp' niet beschrijven. Zorg ervoor dat je 'kubectl describe namespace webapp' hebt uitgevoerd."
    exit 1
fi

if ! kubectl describe namespace database &> /dev/null; then
    echo "Kon namespace 'database' niet beschrijven. Zorg ervoor dat je 'kubectl describe namespace database' hebt uitgevoerd."
    exit 1
fi

# Test of gebruiker YAML output kan bekijken
if ! kubectl get namespace monitoring -o yaml &> /dev/null; then
    echo "Kon namespace 'monitoring' niet in YAML formaat bekijken."
    exit 1
fi

# Controleer of alle verwachte namespaces bestaan
expected_namespaces=("webapp" "database" "monitoring" "development" "production")
for ns in "${expected_namespaces[@]}"; do
    if ! kubectl get namespace "$ns" &> /dev/null; then
        echo "Namespace $ns bestaat niet."
        exit 1
    fi
done

echo "Uitstekend! Je hebt succesvol namespace details bekeken en begrijpt hoe je gedetailleerde informatie kunt verkrijgen."
exit 0