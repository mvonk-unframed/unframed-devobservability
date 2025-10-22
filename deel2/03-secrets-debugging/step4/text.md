# Stap 4: Pod-Secret Verbindingen

## Waarom Pod-Secret Verbindingen Belangrijk Zijn

Het begrijpen van hoe pods secrets gebruiken is cruciaal voor debugging. Applicatie problemen zijn vaak gerelateerd aan verkeerde secret configuratie of ontbrekende verbindingen.

## Pods die Secrets Gebruiken

Bekijk welke pods er draaien in de secrets namespace:

```plain
kubectl get pods -n secrets
```{{exec}}

## Pod Configuratie Analyseren

Bekijk hoe de webapp pod secrets gebruikt:

```plain
kubectl describe pod -n secrets -l app=webapp
```{{exec}}

## Environment Variables van Secrets

Bekijk welke environment variables zijn ingesteld:

```plain
kubectl get pod -n secrets -l app=webapp -o jsonpath='{.items[0].spec.containers[0].env}' | jq .
```{{exec}}

Als `jq` niet beschikbaar is:

```plain
kubectl get pod -n secrets -l app=webapp -o yaml | grep -A 20 "env:"
```{{exec}}

## Volume Mounts van Secrets

Bekijk welke secrets als volumes zijn gemount:

```plain
kubectl get pod -n secrets -l app=webapp -o jsonpath='{.items[0].spec.volumes}' | jq .
```{{exec}}

## Secret Volume Mount Paden

Bekijk waar secrets zijn gemount in de container:

```plain
kubectl get pod -n secrets -l app=webapp -o jsonpath='{.items[0].spec.containers[0].volumeMounts}' | jq .
```{{exec}}

## Exec in Pod om Secret Files te Bekijken

Ga in de pod en bekijk de gemounte secret files:

```plain
kubectl exec -n secrets -l app=webapp -- ls -la /etc/ssl/certs/webapp/
```{{exec}}

Bekijk de inhoud van een secret file:

```plain
kubectl exec -n secrets -l app=webapp -- cat /etc/ssl/certs/webapp/tls.crt | head -5
```{{exec}}

## Environment Variables in Pod Bekijken

Bekijk de environment variables die vanuit secrets komen:

```plain
kubectl exec -n secrets -l app=webapp -- env | grep DB_
```{{exec}}

```plain
kubectl exec -n secrets -l app=webapp -- env | grep STRIPE_KEY
```{{exec}}

## ConfigMap vs Secret Mount

Vergelijk hoe ConfigMaps worden gemount:

```plain
kubectl exec -n secrets -l app=webapp -- ls -la /etc/config/
```{{exec}}

```plain
kubectl exec -n secrets -l app=webapp -- cat /etc/config/app-name
```{{exec}}

## Secret Volume Pod Analyseren

Bekijk de speciale pod die secrets als volume gebruikt:

```plain
kubectl describe pod secret-volume-pod -n secrets
```{{exec}}

Bekijk de secret files in deze pod:

```plain
kubectl exec secret-volume-pod -n secrets -- ls -la /etc/secrets/
```{{exec}}

```plain
kubectl exec secret-volume-pod -n secrets -- cat /etc/secrets/username
```{{exec}}

## ImagePullSecrets Verbinding

Bekijk hoe Docker registry secrets worden gebruikt:

```plain
kubectl get pod -n secrets -l app=webapp -o jsonpath='{.items[0].spec.imagePullSecrets}'
```{{exec}}

## Troubleshooting Broken Pod

Bekijk de broken-webapp pod die verkeerde credentials gebruikt:

```plain
kubectl describe pod -n secrets -l app=broken-webapp
```{{exec}}

Bekijk de environment variables van de broken pod:

```plain
kubectl exec -n secrets -l app=broken-webapp -- env | grep DB_ || echo "Pod might not be running"
```{{exec}}

## Secret Reference Validation

Controleer of alle secret references geldig zijn:

```plain
kubectl get pod -n secrets -l app=webapp -o yaml | grep -A 5 "secretKeyRef:"
```{{exec}}

## Veelvoorkomende Pod-Secret Problemen

### 1. **Missing Secret Reference**
- Pod kan niet starten omdat secret niet bestaat

### 2. **Wrong Secret Key**
- Environment variable is leeg omdat key naam verkeerd is

### 3. **Permission Issues**
- Pod kan secret files niet lezen vanwege file permissions

### 4. **Mount Path Conflicts**
- Meerdere secrets gemount op dezelfde path

## 🎯 Praktische Opdracht

### Opdracht: Pod-Secret Verbinding Analyse

Je gaat nu analyseren hoe pods secrets gebruiken en eventuele problemen identificeren.

1. **Vind een pod die secrets gebruikt** als environment variables
2. **Vind een pod die secrets gebruikt** als volume mounts
3. **Identificeer een broken pod** die verwijst naar een non-existent secret

**Maak een Secret aan** met de naam `pod-secret-analysis`:

```bash
kubectl create secret generic pod-secret-analysis \
  --from-literal=env-pod="<pod-met-env-secrets>" \
  --from-literal=volume-pod="<pod-met-volume-secrets>" \
  --from-literal=broken-pod="<pod-met-missing-secret>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je pod-secret verbindingen kunt identificeren
- ✅ Of je verschillende secret usage patterns begrijpt
- ✅ Of je broken secret references kunt vinden