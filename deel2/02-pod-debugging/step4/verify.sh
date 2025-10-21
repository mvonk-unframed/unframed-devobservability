#!/bin/bash

# Controleer of de gebruiker log commando's heeft uitgevoerd
# We testen dit door te controleren of ze logs kunnen bekijken van verschillende pods

# Controleer of er pods zijn in debugging namespace
pod_count=$(kubectl get pods -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in debugging namespace."
    exit 1
fi

# Test of gebruiker logs kan bekijken van healthy pods
healthy_pod=$(kubectl get pods -n debugging -l app=healthy-app --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$healthy_pod" ]; then
    if ! kubectl logs "$healthy_pod" -n debugging &> /dev/null; then
        echo "Kon logs niet bekijken van healthy pod."
        exit 1
    fi
else
    echo "Geen healthy pod gevonden."
    exit 1
fi

# Test of gebruiker logs kan bekijken van crash pods
crash_pod=$(kubectl get pods -n debugging -l app=crash-app --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$crash_pod" ]; then
    # Test normale logs
    if ! kubectl logs "$crash_pod" -n debugging &> /dev/null; then
        echo "Kon logs niet bekijken van crash pod."
        exit 1
    fi
    
    # Test previous logs (belangrijk voor crashed containers)
    kubectl logs "$crash_pod" -n debugging --previous &> /dev/null
    # Previous logs kunnen falen als er geen previous container is, dus we checken dit niet als error
else
    echo "Geen crash pod gevonden."
    exit 1
fi

# Test of gebruiker logs met timestamps kan bekijken
if ! kubectl logs -l app=healthy-app -n debugging --timestamps &> /dev/null; then
    echo "Kon logs met timestamps niet bekijken."
    exit 1
fi

# Test of gebruiker logs kan beperken met tail
if ! kubectl logs -l app=healthy-app -n debugging --tail=10 &> /dev/null; then
    echo "Kon logs niet beperken met --tail."
    exit 1
fi

# Controleer of er daadwerkelijk logs zijn (niet leeg)
log_lines=$(kubectl logs -l app=healthy-app -n debugging 2>/dev/null | wc -l)
if [ "$log_lines" -eq 0 ]; then
    echo "Geen logs gevonden in healthy pods. Dit kan betekenen dat de pods nog niet gestart zijn."
    # Dit is niet kritiek, nginx pods hebben mogelijk geen logs
fi

echo "Geweldig! Je hebt geleerd hoe je pod logs kunt analyseren voor effectieve debugging. Je beheerst nu basis logs, previous logs, timestamps en filtering."
exit 0