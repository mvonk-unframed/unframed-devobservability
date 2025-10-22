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

## Multiple Choice Vragen

**Vraag 1:** Hoe kun je zien welke secrets een pod gebruikt als environment variables?

A) `kubectl get pod <name> -o yaml | grep -A 10 "env:"`
B) `kubectl describe pod <name>`
C) `kubectl get pod <name> -o jsonpath='{.spec.containers[0].env}'`
D) Alle bovenstaande opties

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: D**

Alle opties werken:
- `kubectl get pod <name> -o yaml | grep -A 10 "env:"` - toont env sectie in YAML
- `kubectl describe pod <name>` - toont environment variables in leesbare vorm
- `kubectl get pod <name> -o jsonpath='{.spec.containers[0].env}'` - toont env als JSON

Elke methode heeft zijn voordelen afhankelijk van wat je wilt zien.
</details>

---

**Vraag 2:** Wat gebeurt er als een pod verwijst naar een non-existent secret?

A) De pod start normaal maar de environment variables zijn leeg
B) De pod kan niet starten en blijft in Pending status
C) Kubernetes maakt automatisch een lege secret aan
D) De pod crasht met een error

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Als een pod verwijst naar een non-existent secret:
- De pod kan niet starten
- Status blijft "Pending"
- Events tonen "FailedMount" of vergelijkbare errors
- Kubernetes wacht tot de secret beschikbaar is

Dit is een safety feature om te voorkomen dat pods starten zonder benodigde credentials.
</details>

---

**Vraag 3:** Wat is het verschil tussen secrets als environment variables vs. volume mounts?

A) Environment variables zijn veiliger
B) Volume mounts zijn sneller
C) Environment variables zijn zichtbaar in proces lijst, volume mounts niet
D) Er is geen verschil

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

Belangrijke verschillen:
- **Environment variables**: Zichtbaar in proces lijst (`ps aux`), minder veilig
- **Volume mounts**: Niet zichtbaar in proces lijst, veiliger
- **Volume mounts**: Kunnen automatisch updaten bij secret wijzigingen
- **Environment variables**: Vereisen pod restart voor updates

Volume mounts zijn over het algemeen veiliger voor gevoelige data.
</details>

---

## Debugging Workflow

1. **Check Pod Status**: Is de pod running?
2. **Verify Secret Exists**: Bestaat de gerefereerde secret?
3. **Check Secret Keys**: Zijn de key namen correct?
4. **Validate Mount Paths**: Zijn er conflicten in mount paths?
5. **Test Access**: Kan de pod de secret data lezen?

Analyseer nu de verschillende pod-secret verbindingen en identificeer eventuele problemen!