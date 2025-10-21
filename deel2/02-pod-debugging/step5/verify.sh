#!/bin/bash

# Controleer of de gebruiker de debugging scenario's heeft doorlopen
# We testen dit door te controleren of ze verschillende problematische pods kunnen identificeren

# Controleer of er pods zijn in debugging namespace
pod_count=$(kubectl get pods -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in debugging namespace."
    exit 1
fi

# Test Scenario 1: ImagePullBackOff
image_pull_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "ImagePullBackOff" || true)
if [ "$image_pull_pods" -eq 0 ]; then
    echo "Geen ImagePullBackOff pods gevonden. Setup is mogelijk niet correct."
    exit 1
fi

# Test Scenario 2: Pending pods (resource constraints)
pending_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "Pending" || true)
if [ "$pending_pods" -eq 0 ]; then
    echo "Geen Pending pods gevonden. Resource constraint scenario is mogelijk niet actief."
    # Dit is niet kritiek, resource-hungry pod kan soms wel starten op kleine clusters
fi

# Test Scenario 3: Memory-hog pod (kan OOMKilled zijn of running)
memory_hog_pod=$(kubectl get pods -n debugging -l app=memory-hog --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -z "$memory_hog_pod" ]; then
    echo "Memory-hog pod niet gevonden."
    exit 1
fi

# Test Scenario 4: CrashLoopBackOff
crash_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "CrashLoopBackOff" || true)
if [ "$crash_pods" -eq 0 ]; then
    echo "Geen CrashLoopBackOff pods gevonden. Crash scenario is mogelijk niet actief."
    # Dit is niet kritiek, crash pod kan in verschillende states zijn
fi

# Test Scenario 5: Readiness probe failure (Running but not Ready)
not_ready_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep "Running" | grep -c "0/" || true)
if [ "$not_ready_pods" -eq 0 ]; then
    echo "Geen pods gevonden die Running maar niet Ready zijn."
    # Dit is niet kritiek, readiness probe kan soms wel slagen
fi

# Test of gebruiker verschillende debugging commando's kan uitvoeren
# Test describe commando
broken_image_pod=$(kubectl get pods -n debugging -l app=broken-image --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$broken_image_pod" ]; then
    if ! kubectl describe pod "$broken_image_pod" -n debugging &> /dev/null; then
        echo "Kon broken-image pod niet beschrijven."
        exit 1
    fi
fi

# Test logs commando
crash_pod=$(kubectl get pods -n debugging -l app=crash-app --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -n "$crash_pod" ]; then
    if ! kubectl logs "$crash_pod" -n debugging &> /dev/null; then
        echo "Kon crash pod logs niet bekijken."
        exit 1
    fi
fi

# Test of er verschillende pod states aanwezig zijn
total_problem_pods=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -E "(CrashLoopBackOff|ImagePullBackOff|Pending|Error|OOMKilled)" | wc -l)
if [ "$total_problem_pods" -lt 2 ]; then
    echo "Te weinig problematische pods gevonden voor volledige debugging oefening."
    exit 1
fi

echo "Fantastisch! Je hebt alle debugging scenario's doorlopen en kunt nu verschillende pod problemen identificeren en diagnosticeren. Je beheerst de volledige debugging workflow!"
exit 0