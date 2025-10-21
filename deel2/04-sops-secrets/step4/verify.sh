#!/bin/bash

# Controleer of de gebruiker encrypted secrets heeft toegepast in Kubernetes

# Test of sops namespace bestaat
if ! kubectl get namespace sops &> /dev/null; then
    echo "SOPS namespace niet gevonden."
    exit 1
fi

# Test of database secret is toegepast
if ! kubectl get secret database-credentials-sops -n sops &> /dev/null; then
    echo "Database credentials secret niet gevonden in Kubernetes."
    exit 1
fi

# Test of API keys secret is toegepast
if ! kubectl get secret api-keys-sops -n sops &> /dev/null; then
    echo "API keys secret niet gevonden in Kubernetes."
    exit 1
fi

# Test of TLS secret is toegepast
if ! kubectl get secret app-tls-sops -n sops &> /dev/null; then
    echo "TLS secret niet gevonden in Kubernetes."
    exit 1
fi

# Controleer of secrets de juiste data bevatten
db_username=$(kubectl get secret database-credentials-sops -n sops -o jsonpath='{.data.username}' 2>/dev/null | base64 -d)
if [ -z "$db_username" ]; then
    echo "Database username niet gevonden in toegepaste secret."
    exit 1
fi

# Controleer API key
stripe_key=$(kubectl get secret api-keys-sops -n sops -o jsonpath='{.data.stripe-key}' 2>/dev/null | base64 -d)
if [ -z "$stripe_key" ]; then
    echo "Stripe API key niet gevonden in toegepaste secret."
    exit 1
fi

# Test of TLS certificate correct is toegepast
tls_cert=$(kubectl get secret app-tls-sops -n sops -o jsonpath='{.data.tls\.crt}' 2>/dev/null | base64 -d)
if [ -z "$tls_cert" ]; then
    echo "TLS certificate niet gevonden in toegepaste secret."
    exit 1
fi

# Controleer of TLS certificate geldig formaat heeft
if ! echo "$tls_cert" | grep -q "BEGIN CERTIFICATE"; then
    echo "TLS certificate heeft niet het juiste formaat."
    exit 1
fi

# Test of demo pod kan worden aangemaakt (probeer eerst te verwijderen als het bestaat)
kubectl delete pod sops-demo-pod -n sops --ignore-not-found=true &> /dev/null

# Maak demo pod aan
cat <<EOF | kubectl apply -f - &> /dev/null
apiVersion: v1
kind: Pod
metadata:
  name: sops-demo-pod
  namespace: sops
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sleep", "60"]
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: database-credentials-sops
          key: username
    - name: STRIPE_KEY
      valueFrom:
        secretKeyRef:
          name: api-keys-sops
          key: stripe-key
EOF

# Wacht tot pod running is
sleep 10

# Test of pod correct is gestart
pod_status=$(kubectl get pod sops-demo-pod -n sops --no-headers 2>/dev/null | awk '{print $3}')
if [ "$pod_status" != "Running" ]; then
    echo "Demo pod is niet running. Status: $pod_status"
    # Niet kritiek voor verificatie, pod kan tijd nodig hebben
fi

# Test of environment variables correct zijn ingesteld (als pod running is)
if [ "$pod_status" = "Running" ]; then
    env_username=$(kubectl exec sops-demo-pod -n sops -- env 2>/dev/null | grep "DB_USERNAME=" | cut -d'=' -f2)
    if [ "$env_username" != "$db_username" ]; then
        echo "Environment variable DB_USERNAME niet correct ingesteld."
        exit 1
    fi
fi

# Test of secret update werkt
original_password=$(kubectl get secret database-credentials-sops -n sops -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)

# Update secret via SOPS
if ! sops --set '["data"]["password"] "dXBkYXRlZHBhc3M="' /root/secrets/database-secret.yaml 2>/dev/null; then
    echo "Kon secret niet updaten via SOPS."
    exit 1
fi

# Apply updated secret
if ! sops -d /root/secrets/database-secret.yaml 2>/dev/null | kubectl apply -f - &> /dev/null; then
    echo "Kon updated secret niet toepassen."
    exit 1
fi

# Controleer of update is doorgevoerd
updated_password=$(kubectl get secret database-credentials-sops -n sops -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)
if [ "$updated_password" != "updatedpass" ]; then
    echo "Secret update niet succesvol doorgevoerd."
    exit 1
fi

# Test of meerdere secrets tegelijk kunnen worden toegepast
secret_count_before=$(kubectl get secrets -n sops --no-headers 2>/dev/null | wc -l)

# Apply alle secrets
for secret in /root/secrets/*-secret.yaml; do
    if ! sops -d "$secret" 2>/dev/null | kubectl apply -f - &> /dev/null; then
        echo "Kon niet alle secrets toepassen."
        exit 1
    fi
done

secret_count_after=$(kubectl get secrets -n sops --no-headers 2>/dev/null | wc -l)
if [ "$secret_count_after" -lt "$secret_count_before" ]; then
    echo "Secret count decreased na bulk apply."
    exit 1
fi

# Cleanup demo pod
kubectl delete pod sops-demo-pod -n sops --ignore-not-found=true &> /dev/null

echo "Fantastisch! Je hebt geleerd hoe je encrypted secrets kunt toepassen in Kubernetes en complete deployment workflows kunt implementeren."
exit 0