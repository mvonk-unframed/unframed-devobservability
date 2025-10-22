# Stap 2: Secret Decrypten met SOPS

## SOPS Decrypt Commando

De basis van SOPS is het kunnen decrypten van encrypted files. Laten we beginnen met het decrypten van de database credentials:

```plain
sops -d /root/secrets/database-secret.yaml
```{{exec}}

## API Keys Decrypten

Bekijk de gedecodeerde API keys:

```plain
sops -d /root/secrets/api-keys-secret.yaml
```{{exec}}

## TLS Certificate Decrypten

Decrypt het TLS certificate secret:

```plain
sops -d /root/secrets/tls-secret.yaml
```{{exec}}

## Specifieke Waarden Extraheren

Je kunt ook specifieke waarden uit encrypted files halen met `--extract`:

```plain
sops -d --extract '["data"]["username"]' /root/secrets/database-secret.yaml
```{{exec}}

Haal de database password op:

```plain
sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml
```{{exec}}

## Base64 Decodering Combineren

Combineer SOPS decrypt met base64 decodering om de echte waarde te zien:

```plain
sops -d --extract '["data"]["username"]' /root/secrets/database-secret.yaml | base64 -d
```{{exec}}

```plain
sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml | base64 -d
```{{exec}}

## JSON Output voor Processing

Voor scripting kun je JSON output gebruiken:

```plain
sops -d --output-type json /root/secrets/api-keys-secret.yaml | jq '.data'
```{{exec}}

## Vergelijking met Plain Secret

Vergelijk met een niet-encrypted secret:

```plain
cat /root/secrets/plain-secret.yaml
```{{exec}}

## SOPS Metadata Bekijken

Bekijk alleen de SOPS metadata zonder te decrypten:

```plain
sops -d --extract '["sops"]' /root/secrets/database-secret.yaml
```{{exec}}

## Encryption Status Controleren

Controleer of een file encrypted is:

```plain
sops filestatus /root/secrets/database-secret.yaml
```{{exec}}

```plain
sops filestatus /root/secrets/plain-secret.yaml
```{{exec}}

## Rotation Secret Decrypten

Bekijk het rotation demo secret:

```plain
sops -d /root/secrets/rotation-secret.yaml
```{{exec}}

## Praktische Use Cases

### 1. **Debugging Credentials**
```bash
# Snel een password checken
sops -d --extract '["data"]["password"]' secret.yaml | base64 -d
```

### 2. **Script Integration**
```bash
# Gebruik in scripts
DB_PASSWORD=$(sops -d --extract '["data"]["password"]' secret.yaml | base64 -d)
```

### 3. **CI/CD Pipelines**
```bash
# Deploy secrets in pipelines
sops -d secret.yaml | kubectl apply -f -
```

## Security Voordelen van Decrypt

1. **On-demand Decryption**: Secrets worden alleen gedecodeerd wanneer nodig
2. **No Persistent Storage**: Gedecodeerde waarden worden niet opgeslagen
3. **Audit Trail**: SOPS kan loggen wie wanneer wat heeft gedecodeerd
4. **Key Access Control**: Alleen mensen met de juiste keys kunnen decrypten

## Wat Zie Je?

Analyseer de output en let op:
1. **Metadata Preservation**: Kubernetes metadata blijft intact
2. **Selective Encryption**: Alleen `data` velden zijn encrypted
3. **SOPS Metadata**: Encryption informatie aan het einde
4. **Base64 Encoding**: Data is nog steeds base64 encoded na decryptie

## 🎯 Praktische Opdracht

### Opdracht: SOPS Decryptie en Waarde Extractie

Je gaat nu SOPS encrypted secrets decrypten en specifieke waarden extraheren.

1. **Decodeer de database secret** en extraheer de username:
   - Gebruik SOPS om de encrypted file te decrypten
   - Extraheer alleen de username waarde
   - Decodeer de base64 waarde om de echte username te zien

2. **Maak een Secret aan** met de naam `sops-analysis` die je bevindingen bevat:

```bash
kubectl create secret generic sops-analysis \
  --from-literal=decrypted-username="<gedecodeerde-username>" \
  --from-literal=sops-version="<sops-versie-uit-metadata>" \
  --from-literal=encryption-method="age"
```

3. **Test SOPS functionaliteit** door een nieuwe encrypted waarde toe te voegen en maak een ConfigMap aan met de naam `sops-test`:

```bash
kubectl create configmap sops-test \
  --from-literal=test-completed="true" \
  --from-literal=new-value-added="<nieuwe-key-naam>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je SOPS kunt gebruiken voor decryptie
- ✅ Of je specifieke waarden kunt extraheren
- ✅ Of je base64 decodering begrijpt na SOPS decryptie

**Tip**: Gebruik [`sops -d --extract '["data"]["username"]' file.yaml | base64 -d`](sops -d --extract '["data"]["username"]' file.yaml | base64 -d) voor directe waarde extractie!