# Stap 2: Service Endpoints Debugging

## Endpoints Concept Begrijpen

Endpoints zijn de daadwerkelijke IP adressen en poorten van pods die traffic van een service ontvangen. Ze worden automatisch beheerd door Kubernetes op basis van service selectors.

## Alle Endpoints Bekijken

Bekijk alle endpoints in de network namespace:

```plain
kubectl get endpoints -n network
```{{exec}}

## Gedetailleerde Endpoint Analyse

Bekijk gedetailleerde informatie van een werkende service:

```plain
kubectl describe endpoints frontend-service -n network
```{{exec}}

Vergelijk met de backend service:

```plain
kubectl describe endpoints backend-service -n network
```{{exec}}

## Broken Service Endpoints

Bekijk waarom de broken service geen endpoints heeft:

```plain
kubectl describe endpoints broken-service -n network
```{{exec}}

## Service Selector vs Pod Labels

Analyseer het probleem door selectors en labels te vergelijken:

```plain
echo "=== BROKEN SERVICE SELECTOR ==="
kubectl get service broken-service -n network -o jsonpath='{.spec.selector}' | jq .
```{{exec}}

```plain
echo "=== BROKEN-APP POD LABELS ==="
kubectl get pods -n network -l app=broken-app -o jsonpath='{.items[*].metadata.labels}' | jq .
```{{exec}}

## Readiness Probe Impact op Endpoints

Bekijk de failing-readiness service:

```plain
kubectl get endpoints failing-readiness-service -n network
```{{exec}}

```plain
kubectl describe endpoints failing-readiness-service -n network
```{{exec}}

Bekijk waarom pods niet ready zijn:

```plain
kubectl get pods -n network -l app=failing-readiness
```{{exec}}

```plain
kubectl describe pod -n network -l app=failing-readiness | grep -A 10 "Readiness:"
```{{exec}}

## Pod IP Adressen vs Endpoints

Vergelijk pod IP adressen met endpoint adressen:

```plain
echo "=== FRONTEND POD IPs ==="
kubectl get pods -n network -l app=frontend -o wide
```{{exec}}

```plain
echo "=== FRONTEND ENDPOINTS ==="
kubectl get endpoints frontend-service -n network -o yaml | grep -A 10 "addresses:"
```{{exec}}

## Port Mapping Controleren

Controleer hoe service ports mappen naar pod ports:

```plain
echo "=== BACKEND SERVICE PORTS ==="
kubectl get service backend-service -n network -o jsonpath='{.spec.ports}' | jq .
```{{exec}}

```plain
echo "=== BACKEND POD PORTS ==="
kubectl get pods -n network -l app=backend -o jsonpath='{.items[*].spec.containers[*].ports}' | jq .
```{{exec}}

## Endpoint Subsets Begrijpen

Bekijk de endpoint subsets structuur:

```plain
kubectl get endpoints frontend-service -n network -o yaml
```{{exec}}

## Database Service Endpoints

Controleer de database service endpoints:

```plain
kubectl describe endpoints database-service -n network
```{{exec}}

Bekijk de database pod readiness:

```plain
kubectl get pods -n network -l app=database
```{{exec}}

## Manual Endpoint Creation (Advanced)

Soms moet je handmatig endpoints maken. Hier is een voorbeeld:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: manual-service
  namespace: network
spec:
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  name: manual-service
  namespace: network
subsets:
- addresses:
  - ip: 8.8.8.8
  ports:
  - port: 53
EOF
```{{exec}}

Bekijk de handmatige endpoints:

```plain
kubectl get endpoints manual-service -n network
```{{exec}}

## Endpoint Troubleshooting Commands

### 1. **Check Service Selector**
```bash
kubectl get service <service> -o jsonpath='{.spec.selector}'
```

### 2. **Check Pod Labels**
```bash
kubectl get pods --show-labels -l <selector>
```

### 3. **Check Pod Readiness**
```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
```

### 4. **Check Endpoint Details**
```bash
kubectl describe endpoints <service>
```

## Fixing the Broken Service

Laten we de broken service repareren door de selector te corrigeren:

```plain
kubectl patch service broken-service -n network -p '{"spec":{"selector":{"app":"broken-app"}}}'
```{{exec}}

Controleer of het probleem is opgelost:

```plain
kubectl get endpoints broken-service -n network
```{{exec}}

## Testing Fixed Service

Test de gerepareerde service:

```plain
kubectl exec debug-pod -n network -- curl -s http://broken-service.network.svc.cluster.local
```{{exec}}

## Endpoint Events Monitoring

Bekijk events gerelateerd aan endpoints:

```plain
kubectl get events -n network --field-selector involvedObject.kind=Endpoints
```{{exec}}

## Veelvoorkomende Endpoint Problemen

### 1. **No Endpoints**
- Service selector komt niet overeen met pod labels
- Pods zijn niet ready (readiness probe faalt)
- Pods bestaan niet

### 2. **Partial Endpoints**
- Sommige pods zijn niet ready
- Pods hebben verschillende labels
- Network policies blokkeren traffic

### 3. **Wrong Endpoints**
- Port mismatch tussen service en pods
- Verkeerde target port configuratie

## Wat Heb Je Geleerd?

Je hebt nu:
- ✅ Endpoints concept begrepen
- ✅ Service selector problemen geïdentificeerd
- ✅ Readiness probe impact op endpoints gezien
- ✅ Een broken service gerepareerd
- ✅ Manual endpoints aangemaakt

Endpoints zijn cruciaal voor service discovery - zonder endpoints kan een service geen traffic routeren!