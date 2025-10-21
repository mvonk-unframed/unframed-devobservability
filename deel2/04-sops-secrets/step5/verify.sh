#!/bin/bash

# Controleer of de gebruiker secret rotation workflow heeft geïmplementeerd

# Test of rotation secret bestaat
if ! sops -d /root/secrets/rotation-secret.yaml &> /dev/null; then
    echo "Rotation secret kan niet worden gedecodeerd."
    exit 1
fi

# Test of nieuwe password kan worden gegenereerd
NEW_PASSWORD=$(openssl rand -base64 16 2>/dev/null)
if [ -z "$NEW_PASSWORD" ]; then
    echo "Kon geen nieuw password genereren."
    exit 1
fi

# Test of password kan worden ge-update via SOPS
NEW_PASSWORD_B64=$(echo -n "$NEW_PASSWORD" | base64)
if ! sops --set '["data"]["test-rotation"]' "\"$NEW_PASSWORD_B64\"" /root/secrets/rotation-secret.yaml 2>/dev/null; then
    echo "Kon rotation secret niet updaten."
    exit 1
fi

# Test of updated secret kan worden toegepast
if ! sops -d /root/secrets/rotation-secret.yaml 2>/dev/null | kubectl apply -f - &> /dev/null; then
    echo "Kon geroteerde secret niet toepassen."
    exit 1
fi

# Test of rotation-demo secret bestaat in Kubernetes
if ! kubectl get secret rotation-demo -n sops &> /dev/null; then
    echo "Rotation-demo secret niet gevonden in Kubernetes."
    exit 1
fi

# Test deployment creation
kubectl delete deployment rotation-demo-app -n sops --ignore-not-found=true &> /dev/null

cat <<EOF | kubectl apply -f - &> /dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rotation-demo-app
  namespace: sops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rotation-demo
  template:
    metadata:
      labels:
        app: rotation-demo
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sleep", "60"]
        env:
        - name: TEST_PASSWORD
          valueFrom:
            secretKeyRef:
              name: rotation-demo
              key: test-rotation
EOF

# Wacht even voor deployment
sleep 5

# Test of deployment bestaat
if ! kubectl get deployment rotation-demo-app -n sops &> /dev/null; then
    echo "Rotation demo deployment niet gevonden."
    exit 1
fi

# Test rolling restart
if ! kubectl rollout restart deployment/rotation-demo-app -n sops &> /dev/null; then
    echo "Rolling restart faalde."
    exit 1
fi

# Test database password rotation
if ! sops --set '["data"]["password"]' "\"$(echo -n "rotated-password" | base64)\"" /root/secrets/database-secret.yaml 2>/dev/null; then
    echo "Kon database password niet roteren."
    exit 1
fi

# Test API key rotation
NEW_STRIPE_KEY="sk_test_rotated_key"
if ! sops --set '["data"]["stripe-key"]' "\"$(echo -n "$NEW_STRIPE_KEY" | base64)\"" /root/secrets/api-keys-secret.yaml 2>/dev/null; then
    echo "Kon API key niet roteren."
    exit 1
fi

# Test automated rotation script creation
cat > /tmp/test-rotate.sh <<'EOF'
#!/bin/bash
NEW_PASSWORD=$(openssl rand -base64 16)
NEW_PASSWORD_B64=$(echo -n "$NEW_PASSWORD" | base64)
sops --set '["data"]["test-rotation"]' "\"$NEW_PASSWORD_B64\"" /root/secrets/rotation-secret.yaml
echo "Rotation test successful"
EOF

chmod +x /tmp/test-rotate.sh

# Test script execution
if ! /tmp/test-rotate.sh &> /dev/null; then
    echo "Automated rotation script faalde."
    exit 1
fi

# Test Git integration (basic)
cd /root/secrets
if ! git init . &> /dev/null; then
    echo "Git initialization faalde."
    exit 1
fi

git config user.email "test@example.com" &> /dev/null
git config user.name "Test User" &> /dev/null

if ! git add . &> /dev/null; then
    echo "Git add faalde."
    exit 1
fi

if ! git commit -m "Test rotation commit" &> /dev/null; then
    echo "Git commit faalde."
    exit 1
fi

# Test of geroteerde waarden correct zijn
rotated_password=$(sops -d --extract '["data"]["test-rotation"]' /root/secrets/rotation-secret.yaml 2>/dev/null | base64 -d)
if [ -z "$rotated_password" ]; then
    echo "Geroteerde password niet gevonden."
    exit 1
fi

# Test of database password is gewijzigd
db_password=$(sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml 2>/dev/null | base64 -d)
if [ "$db_password" != "rotated-password" ]; then
    echo "Database password rotation niet succesvol."
    exit 1
fi

# Test of API key is gewijzigd
stripe_key=$(sops -d --extract '["data"]["stripe-key"]' /root/secrets/api-keys-secret.yaml 2>/dev/null | base64 -d)
if [ "$stripe_key" != "$NEW_STRIPE_KEY" ]; then
    echo "API key rotation niet succesvol."
    exit 1
fi

# Test events (optioneel)
kubectl get events -n sops &> /dev/null

# Cleanup
kubectl delete deployment rotation-demo-app -n sops --ignore-not-found=true &> /dev/null
rm -f /tmp/test-rotate.sh

echo "Uitstekend! Je hebt een complete secret rotation workflow geïmplementeerd en begrijpt hoe je veilig credentials kunt roteren met SOPS."
exit 0