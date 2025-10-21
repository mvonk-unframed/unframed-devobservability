#!/bin/bash

# Controleer of de gebruiker SOPS decrypt commando's heeft uitgevoerd

# Test of SOPS decrypt werkt voor database secret
if ! sops -d /root/secrets/database-secret.yaml &> /dev/null; then
    echo "Kon database secret niet decrypten."
    exit 1
fi

# Test of SOPS decrypt werkt voor API keys secret
if ! sops -d /root/secrets/api-keys-secret.yaml &> /dev/null; then
    echo "Kon API keys secret niet decrypten."
    exit 1
fi

# Test of SOPS decrypt werkt voor TLS secret
if ! sops -d /root/secrets/tls-secret.yaml &> /dev/null; then
    echo "Kon TLS secret niet decrypten."
    exit 1
fi

# Test of extract functionaliteit werkt
username_encrypted=$(sops -d --extract '["data"]["username"]' /root/secrets/database-secret.yaml 2>/dev/null)
if [ -z "$username_encrypted" ]; then
    echo "Kon username niet extraheren uit database secret."
    exit 1
fi

# Test of base64 decodering werkt na extract
username_decoded=$(echo "$username_encrypted" | base64 -d 2>/dev/null)
if [ -z "$username_decoded" ]; then
    echo "Kon username niet base64 decoderen."
    exit 1
fi

# Controleer of de gedecodeerde username correct is
if [ "$username_decoded" != "dbuser" ]; then
    echo "Gedecodeerde username is niet correct. Verwacht: 'dbuser', Gekregen: '$username_decoded'"
    exit 1
fi

# Test password extractie en decodering
password_encrypted=$(sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml 2>/dev/null)
password_decoded=$(echo "$password_encrypted" | base64 -d 2>/dev/null)
if [ -z "$password_decoded" ]; then
    echo "Kon password niet extraheren en decoderen."
    exit 1
fi

# Test JSON output (als jq beschikbaar is)
if command -v jq &> /dev/null; then
    json_data=$(sops -d --output-type json /root/secrets/api-keys-secret.yaml 2>/dev/null | jq '.data' 2>/dev/null)
    if [ -z "$json_data" ]; then
        echo "Kon JSON output niet genereren."
        exit 1
    fi
fi

# Test filestatus commando
if ! sops filestatus /root/secrets/database-secret.yaml &> /dev/null; then
    echo "Kon filestatus niet controleren voor encrypted file."
    exit 1
fi

# Test filestatus voor plain file
if ! sops filestatus /root/secrets/plain-secret.yaml &> /dev/null; then
    echo "Kon filestatus niet controleren voor plain file."
    exit 1
fi

# Test of rotation secret kan worden gedecodeerd
if ! sops -d /root/secrets/rotation-secret.yaml &> /dev/null; then
    echo "Kon rotation secret niet decrypten."
    exit 1
fi

# Test of SOPS metadata kan worden geëxtraheerd
sops_metadata=$(sops -d --extract '["sops"]' /root/secrets/database-secret.yaml 2>/dev/null)
if [ -z "$sops_metadata" ]; then
    echo "Kon SOPS metadata niet extraheren."
    exit 1
fi

# Controleer of gedecodeerde content daadwerkelijk Kubernetes secret format heeft
decrypted_content=$(sops -d /root/secrets/database-secret.yaml 2>/dev/null)
if ! echo "$decrypted_content" | grep -q "apiVersion: v1"; then
    echo "Gedecodeerde content heeft niet het verwachte Kubernetes secret formaat."
    exit 1
fi

if ! echo "$decrypted_content" | grep -q "kind: Secret"; then
    echo "Gedecodeerde content is niet van het type Secret."
    exit 1
fi

# Test of API keys secret de verwachte keys bevat
api_content=$(sops -d /root/secrets/api-keys-secret.yaml 2>/dev/null)
if ! echo "$api_content" | grep -q "stripe-key"; then
    echo "API keys secret bevat geen stripe-key."
    exit 1
fi

echo "Uitstekend! Je hebt geleerd hoe je encrypted secrets kunt decrypten en specifieke waarden kunt extraheren met SOPS."
exit 0