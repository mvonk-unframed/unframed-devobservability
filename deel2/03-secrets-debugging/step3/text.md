# Stap 3: Secret Inhoud Decoderen

## Waarom Base64 Decodering Belangrijk Is

Kubernetes secrets zijn base64 encoded. Voor debugging moet je vaak de echte waarden zien om problemen te identificeren. **Let op**: Dit is alleen voor debugging - in productie moet je voorzichtig zijn met het decoderen van secrets!

## Basis Base64 Decodering

Haal eerst een base64 encoded waarde op:

```plain
kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}'
```{{exec}}

Decodeer deze waarde:

```plain
kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}' | base64 -d
```{{exec}}

## Alle Database Credentials Decoderen

Bekijk alle database credentials:

```plain
echo "Username: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}' | base64 -d)"
```{{exec}}

```plain
echo "Password: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.password}' | base64 -d)"
```{{exec}}

```plain
echo "Host: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.host}' | base64 -d)"
```{{exec}}

```plain
echo "Port: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.port}' | base64 -d)"
```{{exec}}

## API Keys Decoderen

Bekijk de API keys:

```plain
echo "Stripe Key: $(kubectl get secret api-keys -n secrets -o jsonpath='{.data.stripe-key}' | base64 -d)"
```{{exec}}

```plain
echo "SendGrid Key: $(kubectl get secret api-keys -n secrets -o jsonpath='{.data.sendgrid-key}' | base64 -d)"
```{{exec}}

```plain
echo "JWT Secret: $(kubectl get secret api-keys -n secrets -o jsonpath='{.data.jwt-secret}' | base64 -d)"
```{{exec}}

## TLS Certificate Bekijken

Voor TLS certificates kun je de certificate details bekijken:

```plain
kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```{{exec}}

## Docker Registry Credentials

Docker registry secrets hebben een speciale structuur:

```plain
kubectl get secret docker-credentials -n secrets -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```{{exec}}

Als `jq` niet beschikbaar is:

```plain
kubectl get secret docker-credentials -n secrets -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```{{exec}}

## Handige One-liner voor Alle Keys

Een script om alle keys van een secret te decoderen:

```plain
for key in $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data}' | grep -o '"[^"]*"' | tr -d '"'); do
  echo "$key: $(kubectl get secret database-credentials -n secrets -o jsonpath="{.data.$key}" | base64 -d)"
done
```{{exec}}

## Vergelijking met ConfigMap

ConfigMaps zijn niet encoded - vergelijk met een ConfigMap:

```plain
kubectl get configmap app-config -n secrets -o jsonpath='{.data}'
```{{exec}}

## Security Waarschuwingen

### ⚠️ Belangrijke Security Overwegingen:
1. **Decodeer secrets alleen voor debugging**
2. **Deel nooit gedecodeerde secrets**
3. **Gebruik geen echo in productie scripts**
4. **Log geen secret waarden**
5. **Roteer secrets regelmatig**

## Praktische Debugging Scenario's

### Scenario 1: Database Connection Fails
```bash
# Check database credentials
kubectl get secret database-credentials -n secrets -o jsonpath='{.data.host}' | base64 -d
# Verify if hostname is correct
```

### Scenario 2: API Authentication Fails
```bash
# Check API key format
kubectl get secret api-keys -n secrets -o jsonpath='{.data.stripe-key}' | base64 -d
# Verify key starts with expected prefix (sk_test_ for Stripe test keys)
```

### Scenario 3: TLS Certificate Issues
```bash
# Check certificate expiration
kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -dates -noout
```

## 🎯 Praktische Opdracht

### Opdracht: Secret Decodering en Validatie

Je gaat nu secrets decoderen en de inhoud valideren voor debugging doeleinden.

1. **Decodeer database credentials** en valideer de waarden:
   - Username moet een geldige database user zijn
   - Password moet minstens 8 karakters lang zijn
   - Host moet een geldige hostname/IP zijn

2. **Maak een Secret aan** met de naam `credential-validation` die je validatie resultaten bevat:

```bash
kubectl create secret generic credential-validation \
  --from-literal=username-valid="true/false" \
  --from-literal=password-length="<aantal-karakters>" \
  --from-literal=host-format="<hostname-of-ip>"
```

3. **Decodeer een API key** en controleer het formaat. Maak een ConfigMap aan met de naam `api-validation`:

```bash
kubectl create configmap api-validation \
  --from-literal=stripe-key-prefix="<eerste-7-karakters>" \
  --from-literal=jwt-secret-length="<aantal-karakters>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je secrets kunt decoderen en waarden kunt valideren
- ✅ Of je security best practices begrijpt
- ✅ Of je credential formaten kunt controleren

**Waarschuwing**: Decodeer secrets alleen voor debugging - nooit in productie logs!