#!/bin/bash

# Controleer of de gebruiker cross-namespace commando's heeft uitgevoerd
# We testen dit door te controleren of ze de --all-namespaces flag kunnen gebruiken

# Test of gebruiker pods in alle namespaces kan bekijken
if ! kubectl get pods --all-namespaces &> /dev/null; then
    echo "Kon pods in alle namespaces niet bekijken. Zorg ervoor dat je 'kubectl get pods --all-namespaces' hebt uitgevoerd."
    exit 1
fi

# Test of gebruiker de korte versie (-A) kan gebruiken
if ! kubectl get pods -A &> /dev/null; then
    echo "Kon pods met -A flag niet bekijken."
    exit 1
fi

# Test of gebruiker deployments in alle namespaces kan bekijken
if ! kubectl get deployments --all-namespaces &> /dev/null; then
    echo "Kon deployments in alle namespaces niet bekijken."
    exit 1
fi

# Test of gebruiker services in alle namespaces kan bekijken
if ! kubectl get services --all-namespaces &> /dev/null; then
    echo "Kon services in alle namespaces niet bekijken."
    exit 1
fi

# Controleer of er daadwerkelijk resources in meerdere namespaces zijn
total_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ "$total_pods" -lt 5 ]; then
    echo "Er lijken niet genoeg pods in verschillende namespaces te zijn."
    exit 1
fi

# Test of gebruiker kan filteren met grep (optioneel, maar goed om te testen)
nginx_pods=$(kubectl get pods --all-namespaces 2>/dev/null | grep -c nginx || true)
if [ "$nginx_pods" -eq 0 ]; then
    echo "Waarschuwing: Geen nginx pods gevonden, maar dit is niet kritiek."
fi

echo "Fantastisch! Je hebt geleerd hoe je resources across alle namespaces kunt bekijken en het volledige cluster kunt monitoren."
exit 0