#!/bin/bash

# Controleer of de gebruiker resources in verschillende namespaces heeft bekeken
# We testen dit door te controleren of de verwachte resources bestaan

# Controleer pods in webapp namespace
webapp_pods=$(kubectl get pods -n webapp --no-headers 2>/dev/null | wc -l)
if [ "$webapp_pods" -eq 0 ]; then
    echo "Geen pods gevonden in webapp namespace. Zorg ervoor dat je 'kubectl get pods -n webapp' hebt uitgevoerd."
    exit 1
fi

# Controleer pods in database namespace
database_pods=$(kubectl get pods -n database --no-headers 2>/dev/null | wc -l)
if [ "$database_pods" -eq 0 ]; then
    echo "Geen pods gevonden in database namespace. Zorg ervoor dat je 'kubectl get pods -n database' hebt uitgevoerd."
    exit 1
fi

# Controleer deployments in webapp namespace
webapp_deployments=$(kubectl get deployments -n webapp --no-headers 2>/dev/null | wc -l)
if [ "$webapp_deployments" -eq 0 ]; then
    echo "Geen deployments gevonden in webapp namespace."
    exit 1
fi

# Controleer services in webapp namespace
webapp_services=$(kubectl get services -n webapp --no-headers 2>/dev/null | wc -l)
if [ "$webapp_services" -eq 0 ]; then
    echo "Geen services gevonden in webapp namespace."
    exit 1
fi

# Test of gebruiker 'kubectl get all' kan uitvoeren
if ! kubectl get all -n webapp &> /dev/null; then
    echo "Kon niet alle resources in webapp namespace bekijken."
    exit 1
fi

echo "Perfect! Je hebt succesvol resources in verschillende namespaces verkend en begrijpt hoe namespace isolatie werkt."
exit 0