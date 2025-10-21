#!/bin/bash

# Controleer of de gebruiker kubectl describe commando's heeft uitgevoerd
# We testen dit door te controleren of ze pod details kunnen bekijken

# Controleer of er pods zijn in debugging namespace
pod_count=$(kubectl get pods -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in debugging namespace."
    exit 1
fi

# Test of gebruiker een healthy pod kan beschrijven
healthy_pod=$(kubectl get pods -n debugging -l app=healthy-app --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$healthy_pod" ]; then
    if ! kubectl describe pod "$healthy_pod" -n debugging &> /dev/null; then
        echo "Kon healthy pod niet beschrijven."
        exit 1
    fi
else
    echo "Geen healthy pod gevonden."
    exit 1
fi

# Test of gebruiker problematische pods kan identificeren
problem_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -E "(CrashLoopBackOff|ImagePullBackOff|Pending|Error)" | wc -l)
if [ "$problem_pods" -eq 0 ]; then
    echo "Geen problematische pods gevonden voor debugging oefening."
    exit 1
fi

# Test of gebruiker events kan bekijken
if ! kubectl get events -n debugging &> /dev/null; then
    echo "Kon events niet bekijken in debugging namespace."
    exit 1
fi

# Test of er daadwerkelijk events zijn
event_count=$(kubectl get events -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$event_count" -eq 0 ]; then
    echo "Geen events gevonden in debugging namespace."
    exit 1
fi

# Test of gebruiker een specifieke problematische pod kan beschrijven
broken_pod=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -E "(broken-image|resource-hungry|memory-hog)" | head -1 | awk '{print $1}')
if [ -n "$broken_pod" ]; then
    if ! kubectl describe pod "$broken_pod" -n debugging &> /dev/null; then
        echo "Kon problematische pod niet beschrijven."
        exit 1
    fi
else
    echo "Geen bekende problematische pods gevonden."
    exit 1
fi

echo "Excellent! Je hebt geleerd hoe je gedetailleerde pod informatie kunt bekijken en events kunt analyseren voor debugging."
exit 0