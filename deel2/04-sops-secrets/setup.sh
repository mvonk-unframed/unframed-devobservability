#!/bin/bash

# Wacht tot Kubernetes cluster klaar is
echo "Wachten tot Kubernetes cluster klaar is..."
while ! kubectl get nodes &> /dev/null; do
  sleep 2
done

echo "Kubernetes cluster is klaar!"

# Maak sops namespace aan
kubectl create namespace sops --dry-run=client -o yaml | kubectl apply -f -

echo "Installeren van SOPS en Age..."

# Installeer Age (moderne encryptie tool)
AGE_VERSION="1.1.1"
curl -Lo /tmp/age.tar.gz "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
tar -xzf /tmp/age.tar.gz -C /tmp
mv /tmp/age/age /usr/local/bin/
mv /tmp/age/age-keygen /usr/local/bin/
chmod +x /usr/local/bin/age /usr/local/bin/age-keygen

# Installeer SOPS
SOPS_VERSION="3.8.1"
curl -Lo /usr/local/bin/sops "https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
chmod +x /usr/local/bin/sops

echo "Genereren van Age encryption keys..."

# Genereer Age key voor encryptie
mkdir -p /root/.config/sops/age
age-keygen -o /root/.config/sops/age/keys.txt

# Haal de public key op
AGE_PUBLIC_KEY=$(grep "# public key:" /root/.config/sops/age/keys.txt | cut -d' ' -f4)

# Maak SOPS configuratie
cat > /root/.sops.yaml <<EOF
creation_rules:
  - age: $AGE_PUBLIC_KEY
EOF

echo "Age public key: $AGE_PUBLIC_KEY"

# Stel environment variabele in voor SOPS
export SOPS_AGE_KEY_FILE=/root/.config/sops/age/keys.txt
echo "export SOPS_AGE_KEY_FILE=/root/.config/sops/age/keys.txt" >> /root/.bashrc

echo "Aanmaken van encrypted secret files..."

# Maak directory voor secrets
mkdir -p /root/secrets

# 1. Database credentials secret (encrypted)
cat > /root/secrets/database-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials-sops
  namespace: sops
type: Opaque
data:
  username: ZGJ1c2Vy  # dbuser
  password: c3VwZXJzZWNyZXQxMjM=  # supersecret123
  host: cG9zdGdyZXMuZGF0YWJhc2Uuc3ZjLmNsdXN0ZXIubG9jYWw=  # postgres.database.svc.cluster.local
  port: NTQzMg==  # 5432
EOF

# Encrypt het database secret
sops -e -i /root/secrets/database-secret.yaml

# 2. API keys secret (encrypted)
cat > /root/secrets/api-keys-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: api-keys-sops
  namespace: sops
type: Opaque
data:
  stripe-key: c2tfdGVzdF8xMjM0NTY3ODk=  # sk_test_123456789
  sendgrid-key: U0cuYWJjZGVmMTIzNDU2  # SG.abcdef123456
  jwt-secret: bXktc3VwZXItc2VjcmV0LWp3dC1rZXk=  # my-super-secret-jwt-key
  oauth-client-id: Y2xpZW50XzEyMzQ1Ng==  # client_123456
  oauth-client-secret: c2VjcmV0XzEyMzQ1Ng==  # secret_123456
EOF

# Encrypt het API keys secret
sops -e -i /root/secrets/api-keys-secret.yaml

# 3. TLS certificate secret (encrypted)
# Genereer een self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/app-tls.key -out /tmp/app-tls.crt \
  -subj "/CN=app.example.com/O=app"

# Maak TLS secret YAML
cat > /root/secrets/tls-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: app-tls-sops
  namespace: sops
type: kubernetes.io/tls
data:
  tls.crt: $(base64 -w 0 /tmp/app-tls.crt)
  tls.key: $(base64 -w 0 /tmp/app-tls.key)
EOF

# Encrypt het TLS secret
sops -e -i /root/secrets/tls-secret.yaml

# 4. Maak een plain text secret voor vergelijking
cat > /root/secrets/plain-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plain-credentials
  namespace: sops
type: Opaque
data:
  username: dGVzdHVzZXI=  # testuser
  password: dGVzdHBhc3M=  # testpass
EOF

# 5. Maak een secret dat geroteerd moet worden
cat > /root/secrets/rotation-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: rotation-demo
  namespace: sops
type: Opaque
data:
  old-password: b2xkcGFzc3dvcmQ=  # oldpassword
  api-version: djE=  # v1
  last-rotated: MjAyNC0wMS0wMQ==  # 2024-01-01
EOF

# Encrypt het rotation secret
sops -e -i /root/secrets/rotation-secret.yaml

# Cleanup temp files
rm -f /tmp/app-tls.key /tmp/app-tls.crt /tmp/age.tar.gz
rm -rf /tmp/age

echo "Deployen van een plain secret voor vergelijking..."
kubectl apply -f /root/secrets/plain-secret.yaml

echo "Setup voltooid! SOPS is geïnstalleerd en encrypted secrets zijn klaar."
echo ""
echo "SOPS configuratie:"
echo "- Age key file: /root/.config/sops/age/keys.txt"
echo "- SOPS config: /root/.sops.yaml"
echo "- Encrypted secrets: /root/secrets/"
echo ""
echo "Encrypted secret files:"
ls -la /root/secrets/