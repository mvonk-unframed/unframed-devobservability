#!/bin/bash

# Controleer of de gebruiker SOPS edit functionaliteit heeft gebruikt

# Test of --set commando werkt
original_password=$(sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml 2>/dev/null | base64 -d)

# Probeer een waarde te wijzigen
if ! sops --set '["data"]["password"] "dGVzdHBhc3N3b3Jk"' /root/secrets/database-secret.yaml 2>/dev/null; then
    echo "Kon password niet wijzigen met --set commando."
    exit 1
fi

# Controleer of de wijziging is doorgevoerd
new_password=$(sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml 2>/dev/null | base64 -d)
if [ "$new_password" != "testpassword" ]; then
    echo "Password wijziging niet succesvol. Verwacht: 'testpassword', Gekregen: '$new_password'"
    exit 1
fi

# Test in-place editing
if ! sops --in-place --set '["data"]["environment"] "dGVzdA=="' /root/secrets/api-keys-secret.yaml 2>/dev/null; then
    echo "In-place editing werkt niet."
    exit 1
fi

# Controleer of de nieuwe waarde is toegevoegd
environment_value=$(sops -d --extract '["data"]["environment"]' /root/secrets/api-keys-secret.yaml 2>/dev/null | base64 -d)
if [ "$environment_value" != "test" ]; then
    echo "Environment waarde niet correct toegevoegd."
    exit 1
fi

# Test nieuwe secret aanmaken
cat > /tmp/test-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
  namespace: sops
type: Opaque
data:
  testkey: dGVzdHZhbHVl
EOF

# Test encryptie van nieuwe secret
if ! sops -e /tmp/test-secret.yaml > /tmp/encrypted-test-secret.yaml 2>/dev/null; then
    echo "Kon nieuwe secret niet encrypten."
    exit 1
fi

# Controleer of het encrypted bestand SOPS metadata bevat
if ! grep -q "sops:" /tmp/encrypted-test-secret.yaml; then
    echo "Encrypted bestand bevat geen SOPS metadata."
    exit 1
fi

# Test of het encrypted bestand kan worden gedecodeerd
if ! sops -d /tmp/encrypted-test-secret.yaml &> /dev/null; then
    echo "Kon nieuw encrypted bestand niet decrypten."
    exit 1
fi

# Test metadata bewerking
if ! sops --set '["metadata"]["labels"]["test"] "true"' /root/secrets/api-keys-secret.yaml 2>/dev/null; then
    echo "Kon metadata niet bewerken."
    exit 1
fi

# Controleer of metadata wijziging is doorgevoerd
metadata_check=$(sops -d /root/secrets/api-keys-secret.yaml 2>/dev/null | grep -A 5 "metadata:" | grep "test: \"true\"")
if [ -z "$metadata_check" ]; then
    echo "Metadata wijziging niet gevonden."
    exit 1
fi

# Test dry-run validatie
if ! sops -d /root/secrets/database-secret.yaml 2>/dev/null | kubectl apply --dry-run=client -f - &> /dev/null; then
    echo "Secret validatie faalt - bewerkte secret is niet geldig."
    exit 1
fi

# Test backup functionaliteit
if ! cp /root/secrets/database-secret.yaml /tmp/backup-test.yaml 2>/dev/null; then
    echo "Kon backup niet maken."
    exit 1
fi

# Controleer of backup correct is
if ! sops -d /tmp/backup-test.yaml &> /dev/null; then
    echo "Backup bestand is niet geldig."
    exit 1
fi

# Test of rotation secret kan worden bewerkt
if ! sops --set '["data"]["test-rotation"] "dGVzdA=="' /root/secrets/rotation-secret.yaml 2>/dev/null; then
    echo "Kon rotation secret niet bewerken."
    exit 1
fi

# Controleer of nieuwe waarde in rotation secret staat
rotation_test=$(sops -d --extract '["data"]["test-rotation"]' /root/secrets/rotation-secret.yaml 2>/dev/null | base64 -d)
if [ "$rotation_test" != "test" ]; then
    echo "Test waarde niet correct toegevoegd aan rotation secret."
    exit 1
fi

# Cleanup test files
rm -f /tmp/test-secret.yaml /tmp/encrypted-test-secret.yaml /tmp/backup-test.yaml

echo "Excellent! Je hebt geleerd hoe je encrypted secrets kunt bewerken, nieuwe secrets kunt aanmaken en metadata kunt wijzigen met SOPS."
exit 0