# Stap 3: Pod Analyse

## 🔍 Pod Bekijken

In deze stap analyseren we de pod status om te controleren:
- Is de pod gestart?
- Is de pod Ready?
- Waarom zijn sommige pods niet Ready?

## Pod Status Overzicht

Bekijk alle pods in de network namespace:

```plain
kubectl get pods -n network
```{{exec}}

Bekijk pod status in detail:

```plain
echo "=== POD STATUS DETAILS ==="
kubectl get pods -n network -o wide
```{{exec}}

## Pod Readiness Analyse

Controleer welke pods ready zijn en welke niet:

```plain
echo "=== POD READINESS STATUS ==="
kubectl get pods -n network -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount
```{{exec}}

## Pod Details Bekijken

Analyseer pods die problemen hebben:

```plain
echo "=== FRONTEND POD DETAILS ==="
kubectl describe pod $(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].metadata.name}') -n network
```{{exec}}

```plain
echo "=== FAILING READINESS POD DETAILS ==="
kubectl describe pod $(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].metadata.name}') -n network
```{{exec}}

## Readiness Probe Configuratie

Controleer de readiness probe configuratie:

```plain
echo "=== READINESS PROBE CONFIGURATIE ==="
echo "Frontend pod readiness probe:"
kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].spec.containers[0].readinessProbe}' | jq .

echo "Failing readiness pod readiness probe:"
kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].spec.containers[0].readinessProbe}' | jq .

echo "Backend pod readiness probe:"
kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].spec.containers[0].readinessProbe}' | jq . || echo "Geen readiness probe geconfigureerd"
```{{exec}}

## Readiness Probe Testen

Test de readiness probe endpoints handmatig:

```plain
echo "=== READINESS PROBE TESTING ==="
FAILING_POD_IP=$(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].status.podIP}')
echo "Testing failing readiness pod ($FAILING_POD_IP):"

echo "Testing probe endpoint /nonexistent:"
kubectl run --rm -it debug-pod -n network --image=curlimages/curl -- curl -s --connect-timeout 3 http://$FAILING_POD_IP/nonexistent || echo "❌ Probe endpoint faalt"

echo "Testing root endpoint /:"
kubectl run --rm -it debug-pod2 -n network --image=curlimages/curl -- curl -s http://$FAILING_POD_IP/ | head -2
```{{exec}}

## Pod Logs Analyseren

Bekijk pod logs voor errors:

```plain
echo "=== POD LOGS ==="
echo "Frontend pod logs:"
kubectl logs $(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].metadata.name}') -n network --tail=5

echo "Failing readiness pod logs:"
kubectl logs $(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].metadata.name}') -n network --tail=5

echo "Backend pod logs:"
kubectl logs $(kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].metadata.name}') -n network --tail=5
```{{exec}}

## Pod Events Controleren

Bekijk events gerelateerd aan pods:

```plain
echo "=== POD EVENTS ==="
kubectl get events -n network --field-selector involvedObject.kind=Pod --sort-by=.metadata.creationTimestamp
```{{exec}}

## Pod Connectiviteit Testen

Test directe pod connectiviteit:

```plain
echo "=== DIRECTE POD CONNECTIVITEIT ==="
FRONTEND_POD_IP=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}')
echo "Testing frontend pod ($FRONTEND_POD_IP):"
kubectl run --rm -it debug-pod3 -n network --image=curlimages/curl -- curl -s http://$FRONTEND_POD_IP | head -2

BACKEND_POD_IP=$(kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].status.podIP}')
echo "Testing backend pod ($BACKEND_POD_IP):"
kubectl run --rm -it debug-pod4 -n network --image=curlimages/curl -- curl -s http://$BACKEND_POD_IP | head -2
```{{exec}}

## Readiness Probe Repareren

Repareer de failing readiness probe:

```plain
echo "=== READINESS PROBE REPARATIE ==="
kubectl patch deployment failing-readiness -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/path",
    "value": "/"
  }
]'
```{{exec}}

Wacht tot de fix is toegepast:

```plain
echo "Wachten op deployment rollout..."
kubectl rollout status deployment/failing-readiness -n network --timeout=60s
```{{exec}}

## Reparatie Valideren

Controleer of de pod nu ready is:

```plain
echo "=== VALIDATIE NA REPARATIE ==="
kubectl get pods -n network -l app=failing-readiness

echo "Service endpoints na fix:"
kubectl get endpoints failing-readiness-service -n network
```{{exec}}

## Pod Analyse Checklist

### ✅ **Pod Status**
- Pod is in Running status
- Container is gestart zonder errors
- Geen excessive restarts

### ✅ **Readiness**
- Readiness probe is correct geconfigureerd
- Probe endpoint is bereikbaar
- Pod is Ready voor traffic

### ✅ **Connectiviteit**
- Pod IP is toegewezen
- Pod reageert op HTTP requests
- Applicatie draait correct

## 🎯 Praktische Opdracht

### Opdracht: Pod Status en Readiness Analyse

1. **Identificeer pods die niet Ready zijn** en analyseer waarom
2. **Controleer readiness probe configuratie** en test endpoints
3. **Repareer readiness probe problemen** zodat pods Ready worden

**Maak een Secret aan** met de naam `pod-analysis`:

```bash
kubectl create secret generic pod-analysis \
  --from-literal=not-ready-pod="<naam-van-not-ready-pod>" \
  --from-literal=readiness-issue="<readiness-probe-probleem>" \
  --from-literal=fix-applied="<wat-je-hebt-gerepareerd>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je pod readiness status kunt analyseren
- ✅ Of je readiness probe problemen kunt identificeren
- ✅ Of je readiness probe configuratie kunt repareren

**Tip**: Gebruik [`kubectl get pods -n network`](kubectl get pods -n network) om pod status te controleren!

## Volgende Stap

Nu we de pod status hebben geanalyseerd, gaan we in de volgende stap een **praktische troubleshooting oefening** doen!