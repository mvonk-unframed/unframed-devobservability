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

## Multiple Choice Vragen

**Vraag 1:** Waarom zijn Kubernetes secrets base64 encoded?

A) Voor encryptie en security
B) Voor obfuscation, niet voor echte security
C) Om de grootte te verkleinen
D) Voor betere performance

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Base64 encoding in Kubernetes secrets is voor **obfuscation**, NIET voor echte security:
- Het voorkomt dat secrets per ongeluk zichtbaar zijn in logs
- Het is gemakkelijk te decoderen met `base64 -d`
- Voor echte encryptie heb je tools zoals SOPS nodig
- Het is geen vervanging voor proper secret management
</details>

---

**Vraag 2:** Welk commando decodeert een specifieke key uit een secret?

A) `kubectl get secret <name> -o yaml | base64 -d`
B) `kubectl get secret <name> -o jsonpath='{.data.<key>}' | base64 -d`
C) `kubectl decode secret <name> <key>`
D) `kubectl get secret <name> --decode <key>`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Het correcte commando is:
`kubectl get secret <name> -o jsonpath='{.data.<key>}' | base64 -d`

Bijvoorbeeld:
`kubectl get secret database-credentials -o jsonpath='{.data.username}' | base64 -d`

De andere opties bestaan niet in kubectl.
</details>

---

**Vraag 3:** Wat is een belangrijke security overweging bij het decoderen van secrets?

A) Het is altijd veilig om secrets te decoderen
B) Alleen decoderen voor debugging, nooit in productie logs
C) Base64 decoding is niet mogelijk
D) Secrets kunnen niet gedecodeerd worden

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Belangrijke security overwegingen:
- **Alleen decoderen voor debugging doeleinden**
- **Nooit secret waarden loggen in productie**
- **Deel nooit gedecodeerde secrets**
- **Gebruik geen echo in productie scripts**
- **Roteer secrets regelmatig**

Base64 is gemakkelijk te decoderen, dus behandel gedecodeerde waarden als zeer gevoelig.
</details>

---

Nu kun je secret waarden decoderen voor effectieve debugging!