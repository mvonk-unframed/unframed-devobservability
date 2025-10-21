#!/bin/bash

# Controleer of de gebruiker secret inhoud kan decoderen
# We testen dit door te controleren of ze base64 decodering kunnen uitvoeren

# Controleer of secrets namespace bestaat
if ! kubectl get namespace secrets &> /dev/null; then
    echo "Secrets namespace niet gevonden."
    exit 1
fi

# Test of gebruiker base64 encoded waarde kan ophalen
encoded_username=$(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}' 2>/dev/null)
if [ -z "$encoded_username" ]; then
    echo "Kon base64 encoded username niet ophalen."
    exit 1
fi

# Test of gebruiker base64 decodering kan uitvoeren
decoded_username=$(echo "$encoded_username" | base64 -d 2>/dev/null)
if [ -z "$decoded_username" ]; then
    echo "Kon username niet decoderen."
    exit 1
fi

# Controleer of de gedecodeerde waarde correct is (zou 'dbuser' moeten zijn)
if [ "$decoded_username" != "dbuser" ]; then
    echo "Gedecodeerde username is niet correct. Verwacht: 'dbuser', Gekregen: '$decoded_username'"
    exit 1
fi

# Test of gebruiker password kan decoderen
encoded_password=$(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.password}' 2>/dev/null)
decoded_password=$(echo "$encoded_password" | base64 -d 2>/dev/null)
if [ -z "$decoded_password" ]; then
    echo "Kon password niet decoderen."
    exit 1
fi

# Test of gebruiker API keys kan decoderen
encoded_stripe_key=$(kubectl get secret api-keys -n secrets -o jsonpath='{.data.stripe-key}' 2>/dev/null)
decoded_stripe_key=$(echo "$encoded_stripe_key" | base64 -d 2>/dev/null)
if [ -z "$decoded_stripe_key" ]; then
    echo "Kon Stripe API key niet decoderen."
    exit 1
fi

# Test of gebruiker TLS certificate kan bekijken
tls_cert=$(kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' 2>/dev/null | base64 -d 2>/dev/null)
if [ -z "$tls_cert" ]; then
    echo "Kon TLS certificate niet decoderen."
    exit 1
fi

# Test of TLS certificate geldig is (bevat BEGIN CERTIFICATE)
if ! echo "$tls_cert" | grep -q "BEGIN CERTIFICATE"; then
    echo "TLS certificate heeft niet de verwachte structuur."
    exit 1
fi

# Test of gebruiker Docker registry credentials kan decoderen
docker_config=$(kubectl get secret docker-credentials -n secrets -o jsonpath='{.data.\.dockerconfigjson}' 2>/dev/null | base64 -d 2>/dev/null)
if [ -z "$docker_config" ]; then
    echo "Kon Docker registry credentials niet decoderen."
    exit 1
fi

# Test of Docker config JSON structuur heeft
if ! echo "$docker_config" | grep -q "auths"; then
    echo "Docker registry credentials hebben niet de verwachte JSON structuur."
    exit 1
fi

# Test of gebruiker ConfigMap data kan bekijken (voor vergelijking)
configmap_data=$(kubectl get configmap app-config -n secrets -o jsonpath='{.data}' 2>/dev/null)
if [ -z "$configmap_data" ]; then
    echo "Kon ConfigMap data niet bekijken."
    exit 1
fi

echo "Fantastisch! Je hebt geleerd hoe je secret inhoud kunt decoderen en begrijpt het verschil tussen base64 encoded secrets en plain text ConfigMaps."
exit 0