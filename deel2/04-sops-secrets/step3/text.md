# Stap 3: Secret Bewerken met SOPS

## SOPS Editor Concept

Een van de krachtigste features van SOPS is de mogelijkheid om encrypted files direct te bewerken zonder ze eerst handmatig te decrypten.

## Secret Bewerken met SOPS

Open de database secret voor bewerking:

```plain
sops /root/secrets/database-secret.yaml
```{{exec}}

**Opmerking**: Dit opent een editor (nano). Je kunt de waarden bewerken en opslaan met Ctrl+X, Y, Enter.

## Nieuwe Waarde Toevoegen

Laten we een nieuwe waarde toevoegen aan de API keys secret. Eerst bekijken we de huidige inhoud:

```plain
sops -d /root/secrets/api-keys-secret.yaml | grep -A 10 "data:"
```{{exec}}

Nu bewerken we het bestand om een nieuwe API key toe te voegen:

```plain
sops /root/secrets/api-keys-secret.yaml
```{{exec}}

**In de editor kun je een nieuwe regel toevoegen onder de data sectie:**
```yaml
  github-token: Z2hwX3Rva2VuXzEyMzQ1Ng==  # ghp_token_123456
```

## Waarde Wijzigen via Command Line

Voor scripting kun je ook waarden wijzigen via de command line:

```plain
sops --set '["data"]["password"] "bmV3cGFzc3dvcmQxMjM="' /root/secrets/database-secret.yaml
```{{exec}}

Controleer de wijziging:

```plain
sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml | base64 -d
```{{exec}}

## In-place Editing

Voor bulk wijzigingen kun je in-place editing gebruiken:

```plain
sops --in-place --set '["data"]["environment"] "cHJvZHVjdGlvbg=="' /root/secrets/api-keys-secret.yaml
```{{exec}}

## Nieuwe Secret Aanmaken

Maak een nieuwe encrypted secret vanaf scratch:

```plain
cat > /tmp/new-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: new-service-credentials
  namespace: sops
type: Opaque
data:
  username: $(echo -n "serviceuser" | base64)
  password: $(echo -n "servicepass123" | base64)
  api-endpoint: $(echo -n "https://api.service.com" | base64)
EOF
```{{exec}}

Encrypt het nieuwe secret:

```plain
sops -e /tmp/new-secret.yaml > /root/secrets/new-service-secret.yaml
```{{exec}}

Controleer het resultaat:

```plain
cat /root/secrets/new-service-secret.yaml
```{{exec}}

## Key Rotation Simulatie

Laten we het rotation secret bewerken om een key rotation te simuleren:

```plain
sops /root/secrets/rotation-secret.yaml
```{{exec}}

**In de editor kun je wijzigen:**
```yaml
  old-password: bmV3cGFzc3dvcmQxMjM=  # newpassword123
  api-version: djI=  # v2
  last-rotated: MjAyNC0xMi0wMQ==  # 2024-12-01
```

## Diff Bekijken

Bekijk wat er is gewijzigd (als je git gebruikt):

```plain
cd /root/secrets && git init . && git add . && git commit -m "Initial secrets"
```{{exec}}

Na wijzigingen:

```plain
cd /root/secrets && git diff
```{{exec}}

## Backup voor Bewerking

Maak altijd een backup voordat je belangrijke secrets bewerkt:

```plain
cp /root/secrets/database-secret.yaml /root/secrets/database-secret.yaml.backup
```{{exec}}

## Validatie na Bewerking

Controleer altijd of het bewerkte bestand nog geldig is:

```plain
sops -d /root/secrets/database-secret.yaml | kubectl apply --dry-run=client -f -
```{{exec}}

## Metadata Bewerken

Je kunt ook metadata bewerken (labels, annotations):

```plain
sops --set '["metadata"]["labels"]["environment"] "production"' /root/secrets/api-keys-secret.yaml
```{{exec}}

Controleer de wijziging:

```plain
sops -d /root/secrets/api-keys-secret.yaml | grep -A 5 "metadata:"
```{{exec}}

## Best Practices voor Bewerking

### 1. **Altijd Backup**
```bash
cp secret.yaml secret.yaml.backup
```

### 2. **Valideer na Bewerking**
```bash
sops -d secret.yaml | kubectl apply --dry-run=client -f -
```

### 3. **Gebruik Git voor Tracking**
```bash
git add secret.yaml
git commit -m "Update database password"
```

### 4. **Test in Staging Eerst**
```bash
sops -d secret.yaml | kubectl apply -f - --namespace=staging
```

## Security Voordelen

1. **No Plaintext Files**: Secrets blijven altijd encrypted op disk
2. **Atomic Operations**: Bewerking en re-encryption in één stap
3. **Audit Trail**: Git toont wie wat heeft gewijzigd
4. **Key Validation**: SOPS valideert encryption keys bij bewerking

## 🎯 Praktische Opdracht

### Opdracht: SOPS Secret Bewerking

Je gaat nu een SOPS encrypted secret bewerken en de wijzigingen valideren.

1. **Bewerk een encrypted secret** en voeg een nieuwe key toe
2. **Wijzig een bestaande waarde** in het secret
3. **Valideer de wijzigingen** door het secret te decrypten

**Maak een ConfigMap aan** met de naam `sops-editing`:

```bash
kubectl create configmap sops-editing \
  --from-literal=new-key-added="<nieuwe-key-naam>" \
  --from-literal=modified-key="<gewijzigde-key-naam>" \
  --from-literal=edit-successful="true"
```

### Verificatie

De verificatie controleert:
- ✅ Of je SOPS kunt gebruiken voor veilige secret bewerking
- ✅ Of je wijzigingen correct hebt doorgevoerd
- ✅ Of je begrijpt hoe SOPS encryption werkt