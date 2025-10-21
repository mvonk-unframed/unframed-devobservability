# Stap 5: Secret Rotation Workflow

## Waarom Secret Rotation Belangrijk Is

Secret rotation is een essentiële security practice. Credentials moeten regelmatig worden gewijzigd om security risico's te minimaliseren.

## Huidige Secret Status Bekijken

Bekijk de huidige rotation secret:

```plain
sops -d /root/secrets/rotation-secret.yaml
```{{exec}}

Decodeer de waarden om te zien wat er momenteel staat:

```plain
echo "Old password: $(sops -d --extract '["data"]["old-password"]' /root/secrets/rotation-secret.yaml | base64 -d)"
echo "API version: $(sops -d --extract '["data"]["api-version"]' /root/secrets/rotation-secret.yaml | base64 -d)"
echo "Last rotated: $(sops -d --extract '["data"]["last-rotated"]' /root/secrets/rotation-secret.yaml | base64 -d)"
```{{exec}}

## Stap 1: Nieuwe Credentials Genereren

Genereer een nieuw wachtwoord:

```plain
NEW_PASSWORD=$(openssl rand -base64 32)
echo "New password generated: $NEW_PASSWORD"
```{{exec}}

Encode het nieuwe wachtwoord voor Kubernetes:

```plain
NEW_PASSWORD_B64=$(echo -n "$NEW_PASSWORD" | base64)
echo "Base64 encoded: $NEW_PASSWORD_B64"
```{{exec}}

## Stap 2: Secret Updaten met SOPS

Update het rotation secret met nieuwe waarden:

```plain
# Update password
sops --set '["data"]["old-password"]' "\"$NEW_PASSWORD_B64\"" /root/secrets/rotation-secret.yaml

# Update API version
sops --set '["data"]["api-version"]' "$(echo -n 'v3' | base64)" /root/secrets/rotation-secret.yaml

# Update last rotated date
CURRENT_DATE=$(date +%Y-%m-%d)
sops --set '["data"]["last-rotated"]' "$(echo -n "$CURRENT_DATE" | base64)" /root/secrets/rotation-secret.yaml
```{{exec}}

## Stap 3: Wijzigingen Verificeren

Controleer de wijzigingen:

```plain
echo "=== UPDATED VALUES ==="
echo "New password: $(sops -d --extract '["data"]["old-password"]' /root/secrets/rotation-secret.yaml | base64 -d)"
echo "API version: $(sops -d --extract '["data"]["api-version"]' /root/secrets/rotation-secret.yaml | base64 -d)"
echo "Last rotated: $(sops -d --extract '["data"]["last-rotated"]' /root/secrets/rotation-secret.yaml | base64 -d)"
```{{exec}}

## Stap 4: Secret Toepassen in Kubernetes

Pas het geroteerde secret toe:

```plain
sops -d /root/secrets/rotation-secret.yaml | kubectl apply -f -
```{{exec}}

Controleer in Kubernetes:

```plain
kubectl get secret rotation-demo -n sops -o yaml
```{{exec}}

## Stap 5: Applicatie Restart

Simuleer applicatie restart om nieuwe credentials te gebruiken:

```plain
# Maak een demo deployment
cat <<EOF | kubectl apply -f -
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
        command: ["sleep", "3600"]
        env:
        - name: APP_PASSWORD
          valueFrom:
            secretKeyRef:
              name: rotation-demo
              key: old-password
        - name: API_VERSION
          valueFrom:
            secretKeyRef:
              name: rotation-demo
              key: api-version
EOF
```{{exec}}

## Stap 6: Rolling Restart

Voer een rolling restart uit om nieuwe secrets te laden:

```plain
kubectl rollout restart deployment/rotation-demo-app -n sops
```{{exec}}

Controleer de rollout status:

```plain
kubectl rollout status deployment/rotation-demo-app -n sops
```{{exec}}

## Stap 7: Verificatie van Nieuwe Credentials

Controleer of de nieuwe credentials worden gebruikt:

```plain
POD_NAME=$(kubectl get pods -n sops -l app=rotation-demo --no-headers | head -1 | awk '{print $1}')
echo "Checking pod: $POD_NAME"

kubectl exec $POD_NAME -n sops -- env | grep -E "(APP_PASSWORD|API_VERSION)"
```{{exec}}

## Database Password Rotation Scenario

Laten we ook de database password roteren:

```plain
# Genereer nieuw database password
NEW_DB_PASSWORD=$(openssl rand -base64 16)
echo "New DB password: $NEW_DB_PASSWORD"

# Update database secret
sops --set '["data"]["password"]' "\"$(echo -n "$NEW_DB_PASSWORD" | base64)\"" /root/secrets/database-secret.yaml

# Apply updated secret
sops -d /root/secrets/database-secret.yaml | kubectl apply -f -
```{{exec}}

## API Key Rotation

Simuleer API key rotation:

```plain
# Genereer nieuwe API keys
NEW_STRIPE_KEY="sk_test_$(openssl rand -hex 16)"
NEW_JWT_SECRET=$(openssl rand -base64 32)

echo "New Stripe key: $NEW_STRIPE_KEY"
echo "New JWT secret: $NEW_JWT_SECRET"

# Update API keys secret
sops --set '["data"]["stripe-key"]' "\"$(echo -n "$NEW_STRIPE_KEY" | base64)\"" /root/secrets/api-keys-secret.yaml
sops --set '["data"]["jwt-secret"]' "\"$(echo -n "$NEW_JWT_SECRET" | base64)\"" /root/secrets/api-keys-secret.yaml

# Apply updated secret
sops -d /root/secrets/api-keys-secret.yaml | kubectl apply -f -
```{{exec}}

## Automated Rotation Script

Maak een script voor geautomatiseerde rotation:

```plain
cat > /tmp/rotate-secrets.sh <<'EOF'
#!/bin/bash

NAMESPACE="sops"
SECRET_FILE="/root/secrets/rotation-secret.yaml"

echo "=== Starting Secret Rotation ==="

# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)
NEW_PASSWORD_B64=$(echo -n "$NEW_PASSWORD" | base64)

# Update secret with SOPS
sops --set '["data"]["old-password"]' "\"$NEW_PASSWORD_B64\"" "$SECRET_FILE"
sops --set '["data"]["last-rotated"]' "\"$(echo -n "$(date +%Y-%m-%d)" | base64)\"" "$SECRET_FILE"

# Apply to Kubernetes
sops -d "$SECRET_FILE" | kubectl apply -f -

# Restart deployments using this secret
kubectl rollout restart deployment/rotation-demo-app -n "$NAMESPACE"

echo "=== Secret Rotation Complete ==="
echo "New password: $NEW_PASSWORD"
echo "Applied to Kubernetes and restarted applications"
EOF

chmod +x /tmp/rotate-secrets.sh
```{{exec}}

Test het rotation script:

```plain
/tmp/rotate-secrets.sh
```{{exec}}

## Git Integration voor Audit Trail

Simuleer Git workflow voor audit trail:

```plain
cd /root/secrets

# Initialize git if not already done
git init . 2>/dev/null || true
git config user.email "devops@company.com"
git config user.name "DevOps Team"

# Add and commit changes
git add .
git commit -m "Secret rotation: $(date +%Y-%m-%d)"

# Show commit history
git log --oneline -5
```{{exec}}

## Monitoring en Alerting

Controleer events voor secret updates:

```plain
kubectl get events -n sops --field-selector reason=SecretUpdated
```{{exec}}

## Best Practices voor Secret Rotation

### 1. **Scheduled Rotation**
```bash
# Cron job voor maandelijkse rotation
0 2 1 * * /path/to/rotate-secrets.sh
```

### 2. **Zero-Downtime Rotation**
```bash
# Blue-green deployment voor zero downtime
kubectl patch deployment myapp -p '{"spec":{"template":{"metadata":{"annotations":{"rotated":"'$(date)'"}}}}}'
```

### 3. **Validation na Rotation**
```bash
# Test connectivity na rotation
kubectl exec deployment/myapp -- curl -f http://database:5432/health
```

### 4. **Rollback Plan**
```bash
# Backup voor rollback
cp secret.yaml secret.yaml.backup.$(date +%Y%m%d)
```

## Security Voordelen van SOPS Rotation

1. **Encrypted Storage**: Rotated secrets blijven encrypted in Git
2. **Audit Trail**: Git history toont alle rotations
3. **Automated Process**: Scripts kunnen rotation automatiseren
4. **Zero Plaintext**: Geen plaintext secrets tijdens rotation
5. **Team Collaboration**: Meerdere mensen kunnen rotation uitvoeren

Je hebt nu een complete secret rotation workflow geïmplementeerd!