#!/bin/bash

# Controleer of de gebruiker het troubleshooting scenario heeft doorlopen
# We testen dit door te controleren of ze verschillende debugging stappen kunnen uitvoeren

# Controleer of secrets namespace bestaat
if ! kubectl get namespace secrets &> /dev/null; then
    echo "Secrets namespace niet gevonden."
    exit 1
fi

# Test of gebruiker pods kan bekijken
pod_count=$(kubectl get pods -n secrets --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in secrets namespace."
    exit 1
fi

# Test of webapp en broken-webapp pods bestaan
webapp_pod=$(kubectl get pods -n secrets -l app=webapp --no-headers 2>/dev/null | head -1 | awk '{print $1}')
broken_pod=$(kubectl get pods -n secrets -l app=broken-webapp --no-headers 2>/dev/null | head -1 | awk '{print $1}')

if [ -z "$webapp_pod" ]; then
    echo "Webapp pod niet gevonden."
    exit 1
fi

if [ -z "$broken_pod" ]; then
    echo "Broken-webapp pod niet gevonden."
    exit 1
fi

# Test of gebruiker credentials kan vergelijken
good_username=$(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}' 2>/dev/null | base64 -d)
broken_username=$(kubectl get secret broken-db-credentials -n secrets -o jsonpath='{.data.username}' 2>/dev/null | base64 -d)

if [ -z "$good_username" ] || [ -z "$broken_username" ]; then
    echo "Kon database credentials niet vergelijken."
    exit 1
fi

# Controleer of de credentials daadwerkelijk verschillen
if [ "$good_username" = "$broken_username" ]; then
    echo "Database credentials zouden moeten verschillen voor troubleshooting scenario."
    exit 1
fi

# Test of gebruiker API keys kan controleren
stripe_key=$(kubectl get secret api-keys -n secrets -o jsonpath='{.data.stripe-key}' 2>/dev/null | base64 -d)
if [ -z "$stripe_key" ]; then
    echo "Kon Stripe API key niet ophalen."
    exit 1
fi

# Controleer of Stripe key het juiste formaat heeft
if [[ ! "$stripe_key" =~ ^sk_test_ ]]; then
    echo "Stripe key heeft niet het verwachte test formaat."
    exit 1
fi

# Test of gebruiker JWT secret kan controleren
jwt_secret=$(kubectl get secret api-keys -n secrets -o jsonpath='{.data.jwt-secret}' 2>/dev/null | base64 -d)
if [ -z "$jwt_secret" ]; then
    echo "Kon JWT secret niet ophalen."
    exit 1
fi

# Controleer JWT secret lengte
if [ ${#jwt_secret} -lt 10 ]; then
    echo "JWT secret is te kort."
    exit 1
fi

# Test of gebruiker TLS certificate kan controleren
tls_cert=$(kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' 2>/dev/null | base64 -d)
if [ -z "$tls_cert" ]; then
    echo "Kon TLS certificate niet ophalen."
    exit 1
fi

# Controleer of TLS certificate geldig formaat heeft
if ! echo "$tls_cert" | grep -q "BEGIN CERTIFICATE"; then
    echo "TLS certificate heeft niet het juiste formaat."
    exit 1
fi

# Test of gebruiker certificate details kan bekijken
if ! echo "$tls_cert" | openssl x509 -dates -noout &> /dev/null; then
    echo "Kon TLS certificate dates niet bekijken."
    exit 1
fi

# Test of gebruiker events kan bekijken
if ! kubectl get events -n secrets &> /dev/null; then
    echo "Kon events niet bekijken in secrets namespace."
    exit 1
fi

# Test of gebruiker pod environment kan analyseren
if ! kubectl describe pod "$webapp_pod" -n secrets | grep -q "Environment:" 2>/dev/null; then
    echo "Kon environment variables niet vinden in webapp pod."
    exit 1
fi

# Test of broken credentials daadwerkelijk verkeerd zijn
broken_host=$(kubectl get secret broken-db-credentials -n secrets -o jsonpath='{.data.host}' 2>/dev/null | base64 -d)
if [[ "$broken_host" != *"nonexistent"* ]]; then
    echo "Broken credentials lijken niet daadwerkelijk broken te zijn."
    exit 1
fi

echo "Fantastisch! Je hebt het volledige troubleshooting scenario doorlopen en kunt nu credential gerelateerde problemen identificeren en diagnosticeren."
exit 0