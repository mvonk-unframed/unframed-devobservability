# Stap 4: Secret Encrypten en Toepassen

## Encrypted Secrets Toepassen in Kubernetes

Nu je weet hoe je secrets kunt decrypten en bewerken, gaan we ze toepassen in Kubernetes.

## Direct Apply van Encrypted Secret

SOPS kan direct encrypted secrets toepassen zonder tussenbestanden:

```plain
sops -d /root/secrets/database-secret.yaml | kubectl apply -f -
```{{exec}}

## Controleer de Toegepaste Secret

Bekijk de secret in Kubernetes:

```plain
kubectl get secret database-credentials-sops -n sops
```{{exec}}

Bekijk de details:

```plain
kubectl describe secret database-credentials-sops -n sops
```{{exec}}

## API Keys Secret Toepassen

Pas de API keys secret toe:

```plain
sops -d /root/secrets/api-keys-secret.yaml | kubectl apply -f -
```{{exec}}

## TLS Secret Toepassen

Pas het TLS certificate secret toe:

```plain
sops -d /root/secrets/tls-secret.yaml | kubectl apply -f -
```{{exec}}

## Alle Secrets Tegelijk Toepassen

Je kunt meerdere encrypted secrets tegelijk toepassen:

```plain
for secret in /root/secrets/*-secret.yaml; do
  echo "Applying $secret..."
  sops -d "$secret" | kubectl apply -f -
done
```{{exec}}

## Verificatie van Toegepaste Secrets

Controleer alle secrets in de sops namespace:

```plain
kubectl get secrets -n sops
```{{exec}}

## Secret Waarden Controleren

Controleer of de waarden correct zijn toegepast:

```plain
echo "Database username: $(kubectl get secret database-credentials-sops -n sops -o jsonpath='{.data.username}' | base64 -d)"
```{{exec}}

```plain
echo "API Stripe key: $(kubectl get secret api-keys-sops -n sops -o jsonpath='{.data.stripe-key}' | base64 -d)"
```{{exec}}

## Pod Deployment met SOPS Secrets

Maak een pod die de SOPS secrets gebruikt:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sops-demo-pod
  namespace: sops
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sleep", "3600"]
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: database-credentials-sops
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: database-credentials-sops
          key: password
    - name: STRIPE_KEY
      valueFrom:
        secretKeyRef:
          name: api-keys-sops
          key: stripe-key
    volumeMounts:
    - name: tls-certs
      mountPath: /etc/ssl/certs/app
      readOnly: true
  volumes:
  - name: tls-certs
    secret:
      secretName: app-tls-sops
EOF
```{{exec}}

## Pod Environment Variables Controleren

Controleer of de environment variables correct zijn ingesteld:

```plain
kubectl exec sops-demo-pod -n sops -- env | grep -E "(DB_|STRIPE_)"
```{{exec}}

## TLS Certificate in Pod Controleren

Controleer of het TLS certificate correct is gemount:

```plain
kubectl exec sops-demo-pod -n sops -- ls -la /etc/ssl/certs/app/
```{{exec}}

```plain
kubectl exec sops-demo-pod -n sops -- openssl x509 -in /etc/ssl/certs/app/tls.crt -subject -noout
```{{exec}}

## CI/CD Pipeline Simulatie

Simuleer een CI/CD pipeline die encrypted secrets gebruikt:

```plain
#!/bin/bash
echo "=== CI/CD Pipeline Demo ==="
echo "1. Pulling encrypted secrets from Git..."
ls -la /root/secrets/

echo "2. Decrypting and applying secrets..."
sops -d /root/secrets/database-secret.yaml | kubectl apply -f -

echo "3. Deploying application..."
kubectl get pods -n sops

echo "4. Verifying secret access..."
kubectl exec sops-demo-pod -n sops -- env | grep DB_USERNAME
```{{exec}}

## Secret Update Workflow

Simuleer een secret update:

```plain
# 1. Update het encrypted secret
sops --set '["data"]["password"] "bmV3cGFzc3dvcmQxMjM="' /root/secrets/database-secret.yaml

# 2. Apply de wijziging
sops -d /root/secrets/database-secret.yaml | kubectl apply -f -

# 3. Restart pods om nieuwe secret te gebruiken
kubectl delete pod sops-demo-pod -n sops
```{{exec}}

## Recreate Pod met Nieuwe Secret

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sops-demo-pod-updated
  namespace: sops
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sleep", "3600"]
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: database-credentials-sops
          key: password
EOF
```{{exec}}

Controleer de nieuwe password:

```plain
kubectl exec sops-demo-pod-updated -n sops -- env | grep DB_PASSWORD
```{{exec}}

## Rollback Scenario

Als er een probleem is, kun je snel rollback doen:

```plain
# 1. Herstel van backup
cp /root/secrets/database-secret.yaml.backup /root/secrets/database-secret.yaml

# 2. Apply de oude versie
sops -d /root/secrets/database-secret.yaml | kubectl apply -f -
```{{exec}}

## Best Practices voor Production

### 1. **Automated Deployment**
```bash
# In CI/CD pipeline
sops -d secrets.yaml | kubectl apply -f -
```

### 2. **Health Checks**
```bash
# Verify secret after deployment
kubectl get secret mysecret -o jsonpath='{.data.key}' | base64 -d
```

### 3. **Rolling Updates**
```bash
# Update deployment to use new secret
kubectl rollout restart deployment/myapp
```

### 4. **Monitoring**
```bash
# Monitor secret usage
kubectl get events --field-selector reason=FailedMount
```

## Security Voordelen

1. **No Plaintext Storage**: Secrets blijven encrypted tot deployment
2. **Audit Trail**: Git toont alle wijzigingen
3. **Access Control**: Alleen mensen met keys kunnen deployen
4. **Automated Rotation**: Scripts kunnen secrets automatisch updaten

Je kunt nu veilig encrypted secrets deployen in productie omgevingen!