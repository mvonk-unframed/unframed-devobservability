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

**Wat heb je geleerd?**

Identificeer nu de problemen die je hebt gevonden en begrijp hoe je ze zou kunnen oplossen!