#!/bin/bash

# Controleer of SOPS en Age correct zijn geïnstalleerd en geconfigureerd

# Test of SOPS is geïnstalleerd
if ! command -v sops &> /dev/null; then
    echo "SOPS is niet geïnstalleerd."
    exit 1
fi

# Test of Age is geïnstalleerd
if ! command -v age &> /dev/null; then
    echo "Age is niet geïnstalleerd."
    exit 1
fi

# Test of SOPS configuratie bestaat
if [ ! -f /root/.sops.yaml ]; then
    echo "SOPS configuratie bestand niet gevonden."
    exit 1
fi

# Test of Age key file bestaat
if [ ! -f /root/.config/sops/age/keys.txt ]; then
    echo "Age key file niet gevonden."
    exit 1
fi

# Test of SOPS_AGE_KEY_FILE environment variabele is ingesteld
if [ -z "$SOPS_AGE_KEY_FILE" ]; then
    echo "SOPS_AGE_KEY_FILE environment variabele niet ingesteld."
    exit 1
fi

# Test of de environment variabele naar het juiste bestand wijst
if [ "$SOPS_AGE_KEY_FILE" != "/root/.config/sops/age/keys.txt" ]; then
    echo "SOPS_AGE_KEY_FILE wijst naar verkeerd bestand."
    exit 1
fi

# Test of secrets directory bestaat
if [ ! -d /root/secrets ]; then
    echo "Secrets directory niet gevonden."
    exit 1
fi

# Test of encrypted secret files bestaan
expected_files=("database-secret.yaml" "api-keys-secret.yaml" "tls-secret.yaml" "plain-secret.yaml" "rotation-secret.yaml")
for file in "${expected_files[@]}"; do
    if [ ! -f "/root/secrets/$file" ]; then
        echo "Secret file $file niet gevonden."
        exit 1
    fi
done

# Test of database-secret.yaml daadwerkelijk encrypted is
if ! grep -q "sops:" /root/secrets/database-secret.yaml; then
    echo "Database secret lijkt niet encrypted te zijn met SOPS."
    exit 1
fi

# Test of plain-secret.yaml NIET encrypted is
if grep -q "sops:" /root/secrets/plain-secret.yaml; then
    echo "Plain secret zou niet encrypted moeten zijn."
    exit 1
fi

# Test of sops namespace bestaat
if ! kubectl get namespace sops &> /dev/null; then
    echo "SOPS namespace niet gevonden."
    exit 1
fi

# Test of er minstens één secret in sops namespace is (plain-secret)
secret_count=$(kubectl get secrets -n sops --no-headers 2>/dev/null | wc -l)
if [ "$secret_count" -eq 0 ]; then
    echo "Geen secrets gevonden in sops namespace."
    exit 1
fi

# Test of SOPS versie kan worden opgevraagd
if ! sops --version &> /dev/null; then
    echo "Kon SOPS versie niet opvragen."
    exit 1
fi

# Test of Age versie kan worden opgevraagd
if ! age --version &> /dev/null; then
    echo "Kon Age versie niet opvragen."
    exit 1
fi

# Test of Age public key kan worden gelezen
if ! grep -q "# public key:" /root/.config/sops/age/keys.txt; then
    echo "Age public key niet gevonden in key file."
    exit 1
fi

echo "Uitstekend! SOPS en Age zijn correct geïnstalleerd en geconfigureerd. Je bent klaar om encrypted secrets te beheren."
exit 0