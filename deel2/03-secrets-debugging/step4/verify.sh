#!/bin/bash

# Controleer of de gebruiker pod-secret verbindingen heeft geanalyseerd
# We testen dit door te controleren of ze pod configuraties kunnen bekijken

# Controleer of secrets namespace bestaat
if ! kubectl get namespace secrets &> /dev/null; then
    echo "Secrets namespace niet gevonden."
    exit 1
fi

# Controleer of er pods zijn in secrets namespace
pod_count=$(kubectl get pods -n secrets --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in secrets namespace."
    exit 1
fi

# Test of gebruiker webapp pod kan beschrijven
webapp_pod=$(kubectl get pods -n secrets -l app=webapp --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -z "$webapp_pod" ]; then
    echo "Webapp pod niet gevonden."
    exit 1
fi

if ! kubectl describe pod "$webapp_pod" -n secrets &> /dev/null; then
    echo "Kon webapp pod niet beschrijven."
    exit 1
fi

# Test of gebruiker environment variables kan bekijken
if ! kubectl get pod "$webapp_pod" -n secrets -o yaml | grep -q "env:" 2>/dev/null; then
    echo "Kon environment variables niet vinden in webapp pod."
    exit 1
fi

# Test of gebruiker volume mounts kan bekijken
if ! kubectl get pod "$webapp_pod" -n secrets -o yaml | grep -q "volumeMounts:" 2>/dev/null; then
    echo "Kon volume mounts niet vinden in webapp pod."
    exit 1
fi

# Test of secret-volume-pod bestaat
if ! kubectl get pod secret-volume-pod -n secrets &> /dev/null; then
    echo "Secret-volume-pod niet gevonden."
    exit 1
fi

# Test of gebruiker secret-volume-pod kan beschrijven
if ! kubectl describe pod secret-volume-pod -n secrets &> /dev/null; then
    echo "Kon secret-volume-pod niet beschrijven."
    exit 1
fi

# Test of gebruiker exec commando's kan uitvoeren (als pod running is)
webapp_status=$(kubectl get pod "$webapp_pod" -n secrets --no-headers 2>/dev/null | awk '{print $3}')
if [ "$webapp_status" = "Running" ]; then
    # Test of gebruiker files in pod kan bekijken
    if ! kubectl exec "$webapp_pod" -n secrets -- ls /etc/ssl/certs/webapp/ &> /dev/null; then
        echo "Kon secret files niet bekijken in webapp pod."
        exit 1
    fi
    
    # Test of gebruiker environment variables in pod kan bekijken
    if ! kubectl exec "$webapp_pod" -n secrets -- env | grep -q "DB_" 2>/dev/null; then
        echo "Kon database environment variables niet vinden in webapp pod."
        exit 1
    fi
else
    echo "Webapp pod is niet running, exec tests overgeslagen."
fi

# Test secret-volume-pod exec (als running)
secret_pod_status=$(kubectl get pod secret-volume-pod -n secrets --no-headers 2>/dev/null | awk '{print $3}')
if [ "$secret_pod_status" = "Running" ]; then
    if ! kubectl exec secret-volume-pod -n secrets -- ls /etc/secrets/ &> /dev/null; then
        echo "Kon secret files niet bekijken in secret-volume-pod."
        exit 1
    fi
else
    echo "Secret-volume-pod is niet running, exec tests overgeslagen."
fi

# Test of gebruiker imagePullSecrets kan bekijken
if ! kubectl get pod "$webapp_pod" -n secrets -o yaml | grep -q "imagePullSecrets:" 2>/dev/null; then
    echo "Kon imagePullSecrets niet vinden in webapp pod."
    exit 1
fi

# Test of broken-webapp pod bestaat
broken_pod=$(kubectl get pods -n secrets -l app=broken-webapp --no-headers 2>/dev/null | head -1 | awk '{print $1}')
if [ -z "$broken_pod" ]; then
    echo "Broken-webapp pod niet gevonden."
    exit 1
fi

# Test of gebruiker secret references kan valideren
if ! kubectl get pod "$webapp_pod" -n secrets -o yaml | grep -q "secretKeyRef:" 2>/dev/null; then
    echo "Kon secret references niet vinden in webapp pod."
    exit 1
fi

echo "Uitstekend! Je hebt geleerd hoe je pod-secret verbindingen kunt analyseren en begrijpt hoe secrets worden gebruikt door applicaties."
exit 0