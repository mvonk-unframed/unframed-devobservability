# Stap 5: Credential Troubleshooting Scenario

## Praktische Debugging Oefening

Nu ga je de geleerde technieken toepassen op een echte troubleshooting scenario. Er is een probleem gemeld: "De webapp kan niet verbinden met de database!"

## Scenario: Database Connectie Faalt

### Stap 1: Identificeer het Probleem

Bekijk de status van alle pods:

```plain
kubectl get pods -n secrets
```{{exec}}

Zijn er pods die problemen hebben?

### Stap 2: Analyseer de Werkende Webapp

Bekijk welke credentials de werkende webapp gebruikt:

```plain
kubectl describe pod -n secrets -l app=webapp | grep -A 10 "Environment:"
```{{exec}}

### Stap 3: Analyseer de Broken Webapp

Bekijk welke credentials de broken webapp gebruikt:

```plain
kubectl describe pod -n secrets -l app=broken-webapp | grep -A 10 "Environment:"
```{{exec}}

### Stap 4: Vergelijk de Database Credentials

Bekijk de goede database credentials:

```plain
echo "=== GOEDE CREDENTIALS ==="
echo "Username: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.username}' | base64 -d)"
echo "Password: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.password}' | base64 -d)"
echo "Host: $(kubectl get secret database-credentials -n secrets -o jsonpath='{.data.host}' | base64 -d)"
```{{exec}}

Bekijk de broken database credentials:

```plain
echo "=== BROKEN CREDENTIALS ==="
echo "Username: $(kubectl get secret broken-db-credentials -n secrets -o jsonpath='{.data.username}' | base64 -d)"
echo "Password: $(kubectl get secret broken-db-credentials -n secrets -o jsonpath='{.data.password}' | base64 -d)"
echo "Host: $(kubectl get secret broken-db-credentials -n secrets -o jsonpath='{.data.host}' | base64 -d)"
```{{exec}}

### Stap 5: Test Database Connectivity

Test of de database host bereikbaar is vanuit de werkende pod:

```plain
kubectl exec -n secrets -l app=webapp -- nslookup postgres.database.svc.cluster.local || echo "DNS lookup failed"
```{{exec}}

Test vanuit de broken pod:

```plain
kubectl exec -n secrets -l app=broken-webapp -- nslookup nonexistent.database.svc.cluster.local || echo "DNS lookup failed (expected)"
```{{exec}}

## Scenario: API Key Problemen

### Controleer API Key Formaat

Bekijk de Stripe API key:

```plain
stripe_key=$(kubectl get secret api-keys -n secrets -o jsonpath='{.data.stripe-key}' | base64 -d)
echo "Stripe Key: $stripe_key"
echo "Key starts with: ${stripe_key:0:7}"
```{{exec}}

Stripe test keys zouden moeten beginnen met `sk_test_`.

### Controleer JWT Secret Lengte

```plain
jwt_secret=$(kubectl get secret api-keys -n secrets -o jsonpath='{.data.jwt-secret}' | base64 -d)
echo "JWT Secret length: ${#jwt_secret} characters"
```{{exec}}

JWT secrets zouden minstens 32 karakters lang moeten zijn.

## Scenario: TLS Certificate Problemen

### Controleer Certificate Geldigheid

```plain
kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -dates -noout
```{{exec}}

### Controleer Certificate Subject

```plain
kubectl get secret webapp-tls -n secrets -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -subject -noout
```{{exec}}

### Controleer Certificate in Pod

```plain
kubectl exec -n secrets -l app=webapp -- openssl x509 -in /etc/ssl/certs/webapp/tls.crt -dates -noout
```{{exec}}

## Scenario: Missing Secret Reference

### Simuleer Missing Secret

Probeer een non-existent secret te bekijken:

```plain
kubectl get secret non-existent-secret -n secrets || echo "Secret not found (expected)"
```{{exec}}

### Controleer Pod Events voor Missing Secrets

```plain
kubectl get events -n secrets --field-selector reason=FailedMount
```{{exec}}

## Troubleshooting Checklist

### Voor Database Connection Issues:
1. ✅ **Secret Exists**: Bestaat de database secret?
2. ✅ **Correct Keys**: Zijn username, password, host correct?
3. ✅ **DNS Resolution**: Is de database host bereikbaar?
4. ✅ **Network Connectivity**: Kan de pod de database bereiken?

### Voor API Authentication Issues:
1. ✅ **Key Format**: Heeft de API key het juiste formaat?
2. ✅ **Key Length**: Is de key lang genoeg?
3. ✅ **Key Prefix**: Begint de key met het verwachte prefix?
4. ✅ **Key Expiration**: Is de key nog geldig?

### Voor TLS Certificate Issues:
1. ✅ **Certificate Validity**: Is het certificate nog geldig?
2. ✅ **Subject Match**: Komt de subject overeen met de hostname?
3. ✅ **File Permissions**: Kan de applicatie het certificate lezen?
4. ✅ **Certificate Chain**: Is de volledige certificate chain aanwezig?

## Oplossingen Implementeren

### Fix Database Connection

Om de broken webapp te fixen, zou je de deployment moeten updaten om de juiste secret te gebruiken:

```plain
kubectl patch deployment broken-webapp -n secrets -p '{"spec":{"template":{"spec":{"containers":[{"name":"webapp","env":[{"name":"DB_USERNAME","valueFrom":{"secretKeyRef":{"name":"database-credentials","key":"username"}}},{"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"name":"database-credentials","key":"password"}}},{"name":"DB_HOST","valueFrom":{"secretKeyRef":{"name":"database-credentials","key":"host"}}}]}]}}}}'
```{{exec}}

## Multiple Choice Vragen

**Vraag 1:** Een webapp kan niet verbinden met de database. Wat is de eerste stap in je debugging proces?

A) De database server herstarten
B) Controleren of de database credentials correct zijn
C) De pod status en events bekijken
D) De secret opnieuw aanmaken

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

De debugging workflow begint altijd met:
1. **Pod status controleren** - draait de pod?
2. **Events bekijken** - zijn er error messages?
3. **Dan pas** credentials, connectivity, etc. controleren

Events vertellen je vaak direct wat er mis is, wat tijd bespaart.
</details>

---

**Vraag 2:** Je ziet dat een API key begint met "sk_live_" maar de applicatie verwacht een test key. Wat is het probleem?

A) De key is te kort
B) Er wordt een production key gebruikt in plaats van een test key
C) De key is expired
D) De key heeft het verkeerde formaat

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Stripe API key prefixes:
- **sk_test_**: Test/development keys
- **sk_live_**: Production keys

Als de applicatie een test key verwacht maar een live key krijgt, kan dit authentication problemen veroorzaken of ongewenste charges in productie.
</details>

---

**Vraag 3:** Een TLS certificate is verlopen. Welk commando toont de expiration date?

A) `kubectl get secret <name> --show-expiry`
B) `kubectl describe secret <name> | grep expiry`
C) `kubectl get secret <name> -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -dates -noout`
D) `kubectl get secret <name> --check-validity`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

Het correcte commando is:
`kubectl get secret <name> -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -dates -noout`

Dit:
1. Haalt het certificate op uit de secret
2. Decodeert de base64 encoding
3. Gebruikt openssl om de validity dates te tonen

De andere opties bestaan niet in kubectl.
</details>

---

**Vraag 4:** Wat is de beste manier om een broken deployment te fixen die de verkeerde secret gebruikt?

A) De secret hernoemen naar de naam die de deployment verwacht
B) De deployment patchen om naar de juiste secret te verwijzen
C) Een nieuwe pod handmatig aanmaken
D) De hele namespace verwijderen en opnieuw aanmaken

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

De beste aanpak is de deployment patchen:
- Gebruik `kubectl patch deployment` of `kubectl edit deployment`
- Update de secret references naar de juiste secret
- Kubernetes zal automatisch nieuwe pods uitrollen
- Dit is veiliger dan secrets hernoemen (kan andere apps breken)
</details>

---

**Wat heb je geleerd?**

Identificeer nu de problemen die je hebt gevonden en begrijp hoe je ze zou kunnen oplossen!