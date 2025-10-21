#!/bin/bash

# Controleer of de gebruiker de default namespace heeft kunnen instellen
# We testen dit door te controleren of ze context commando's kunnen uitvoeren

# Test of gebruiker context kan bekijken
if ! kubectl config current-context &> /dev/null; then
    echo "Kon huidige context niet bekijken. Zorg ervoor dat je 'kubectl config current-context' hebt uitgevoerd."
    exit 1
fi

# Test of gebruiker contexts kan bekijken
if ! kubectl config get-contexts &> /dev/null; then
    echo "Kon contexts niet bekijken. Zorg ervoor dat je 'kubectl config get-contexts' hebt uitgevoerd."
    exit 1
fi

# Test of gebruiker namespace kan instellen (we testen door het te proberen)
if ! kubectl config set-context --current --namespace=default &> /dev/null; then
    echo "Kon default namespace niet instellen."
    exit 1
fi

# Test of de namespace instelling werkt door pods te bekijken
if ! kubectl get pods &> /dev/null; then
    echo "Kon pods niet bekijken na namespace instelling."
    exit 1
fi

# Zet namespace terug naar default voor consistentie
kubectl config set-context --current --namespace=default &> /dev/null

echo "Geweldig! Je hebt geleerd hoe je de default namespace kunt instellen en efficiënter kunt werken met kubectl."
exit 0