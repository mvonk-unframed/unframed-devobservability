#!/bin/bash

# Controleer of de gebruiker pods in debugging namespace heeft bekeken
# We testen dit door te controleren of de debugging namespace bestaat en pods bevat

# Controleer of debugging namespace bestaat
if ! kubectl get namespace debugging &> /dev/null; then
    echo "Debugging namespace niet gevonden. Zorg ervoor dat de setup correct is uitgevoerd."
    exit 1
fi

# Controleer of er pods in debugging namespace zijn
pod_count=$(kubectl get pods -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in debugging namespace. Zorg ervoor dat je 'kubectl get pods -n debugging' hebt uitgevoerd."
    exit 1
fi

# Controleer of er pods met verschillende statussen zijn
running_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "Running" || true)
problem_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -E "(CrashLoopBackOff|ImagePullBackOff|Pending|Error)" | wc -l || true)

if [ "$running_pods" -eq 0 ]; then
    echo "Geen running pods gevonden. Er zou minstens één healthy pod moeten zijn."
    exit 1
fi

if [ "$problem_pods" -eq 0 ]; then
    echo "Geen probleem pods gevonden. Er zouden pods met problemen moeten zijn voor debugging oefening."
    exit 1
fi

# Test of gebruiker wide output kan bekijken
if ! kubectl get pods -n debugging -o wide &> /dev/null; then
    echo "Kon pods niet bekijken met -o wide flag."
    exit 1
fi

echo "Uitstekend! Je hebt succesvol pod statussen bekeken en begrijpt de verschillende states waarin pods kunnen zijn."
exit 0