#!/bin/bash

# Controleer of de gebruiker secrets heeft bekeken
# We testen dit door te controleren of de secrets namespace bestaat en secrets bevat

# Controleer of secrets namespace bestaat
if ! kubectl get namespace secrets &> /dev/null; then
    echo "Secrets namespace niet gevonden. Zorg ervoor dat de setup correct is uitgevoerd."
    exit 1
fi

# Controleer of er secrets zijn in de secrets namespace
secret_count=$(kubectl get secrets -n secrets --no-headers 2>/dev/null | wc -l)
if [ "$secret_count" -eq 0 ]; then
    echo "Geen secrets gevonden in secrets namespace. Zorg ervoor dat je 'kubectl get secrets -n secrets' hebt uitgevoerd."
    exit 1
fi

# Controleer of er verschillende types secrets zijn
opaque_secrets=$(kubectl get secrets -n secrets --field-selector type=Opaque --no-headers 2>/dev/null | wc -l)
tls_secrets=$(kubectl get secrets -n secrets --field-selector type=kubernetes.io/tls --no-headers 2>/dev/null | wc -l)
docker_secrets=$(kubectl get secrets -n secrets --field-selector type=kubernetes.io/dockerconfigjson --no-headers 2>/dev/null | wc -l)

if [ "$opaque_secrets" -eq 0 ]; then
    echo "Geen Opaque secrets gevonden."
    exit 1
fi

if [ "$tls_secrets" -eq 0 ]; then
    echo "Geen TLS secrets gevonden."
    exit 1
fi

if [ "$docker_secrets" -eq 0 ]; then
    echo "Geen Docker registry secrets gevonden."
    exit 1
fi

# Controleer of er ook ConfigMaps zijn (voor vergelijking)
configmap_count=$(kubectl get configmaps -n secrets --no-headers 2>/dev/null | wc -l)
if [ "$configmap_count" -eq 0 ]; then
    echo "Geen ConfigMaps gevonden voor vergelijking."
    exit 1
fi

# Test of gebruiker secrets met wide output kan bekijken
if ! kubectl get secrets -n secrets -o wide &> /dev/null; then
    echo "Kon secrets niet bekijken met -o wide flag."
    exit 1
fi

# Controleer of verwachte secrets bestaan
expected_secrets=("database-credentials" "api-keys" "webapp-tls" "docker-credentials")
for secret in "${expected_secrets[@]}"; do
    if ! kubectl get secret "$secret" -n secrets &> /dev/null; then
        echo "Verwachte secret '$secret' niet gevonden."
        exit 1
    fi
done

echo "Uitstekend! Je hebt succesvol secrets verkend en begrijpt de verschillende types en hun eigenschappen."
exit 0