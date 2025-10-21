#!/bin/bash

# Controleer of de gebruiker secret details heeft bekeken
# We testen dit door te controleren of ze verschillende secret details kunnen bekijken

# Controleer of secrets namespace bestaat
if ! kubectl get namespace secrets &> /dev/null; then
    echo "Secrets namespace niet gevonden."
    exit 1
fi

# Test of gebruiker database-credentials secret kan beschrijven
if ! kubectl describe secret database-credentials -n secrets &> /dev/null; then
    echo "Kon database-credentials secret niet beschrijven."
    exit 1
fi

# Test of gebruiker YAML output kan bekijken
if ! kubectl get secret database-credentials -n secrets -o yaml &> /dev/null; then
    echo "Kon database-credentials secret niet bekijken in YAML formaat."
    exit 1
fi

# Test of gebruiker TLS secret kan beschrijven
if ! kubectl describe secret webapp-tls -n secrets &> /dev/null; then
    echo "Kon webapp-tls secret niet beschrijven."
    exit 1
fi

# Test of gebruiker Docker registry secret kan beschrijven
if ! kubectl describe secret docker-credentials -n secrets &> /dev/null; then
    echo "Kon docker-credentials secret niet beschrijven."
    exit 1
fi

# Test of gebruiker ConfigMap kan beschrijven (voor vergelijking)
if ! kubectl describe configmap app-config -n secrets &> /dev/null; then
    echo "Kon app-config ConfigMap niet beschrijven."
    exit 1
fi

# Controleer of secret daadwerkelijk data bevat
data_keys=$(kubectl get secret database-credentials -n secrets -o jsonpath='{.data}' 2>/dev/null)
if [ -z "$data_keys" ]; then
    echo "Database-credentials secret bevat geen data."
    exit 1
fi

# Test of gebruiker secret keys kan bekijken
if ! kubectl get secret database-credentials -n secrets -o jsonpath='{.data}' &> /dev/null; then
    echo "Kon secret keys niet bekijken."
    exit 1
fi

# Controleer of TLS secret de juiste keys heeft
tls_cert=$(kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' 2>/dev/null)
tls_key=$(kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.key}' 2>/dev/null)

if [ -z "$tls_cert" ] || [ -z "$tls_key" ]; then
    echo "TLS secret mist tls.crt of tls.key."
    exit 1
fi

# Controleer of Docker secret de juiste structuur heeft
docker_config=$(kubectl get secret docker-credentials -n secrets -o jsonpath='{.data.\.dockerconfigjson}' 2>/dev/null)
if [ -z "$docker_config" ]; then
    echo "Docker registry secret mist .dockerconfigjson."
    exit 1
fi

echo "Excellent! Je hebt geleerd hoe je gedetailleerde secret informatie kunt bekijken en begrijpt de verschillende secret types en hun structuur."
exit 0