# Stap 3: Service naar Pod Debugging

## ⚖️ Service Endpoints Analysis

Nu services bereikbaar zijn via ingress, gaan we controleren of services correct traffic naar pods routeren. Dit is waar de meeste "service heeft geen endpoints" problemen ontstaan.

## Service Endpoints Status

Bekijk welke services endpoints hebben:

```plain
echo "=== SERVICE ENDPOINTS OVERVIEW ==="
kubectl get endpoints -n network
```{{exec}}

Identificeer services zonder endpoints:

```plain
kubectl get endpoints -n network | grep "<none>" || echo "✅ Alle services hebben endpoints"
```{{exec}}

## Endpoints Detailed Analysis

Analyseer endpoints van werkende services:

```plain
echo "=== FRONTEND SERVICE ENDPOINTS ==="
kubectl describe endpoints frontend-service -n network

echo "=== BACKEND SERVICE ENDPOINTS ==="
kubectl describe endpoints backend-service -n network
```{{exec}}

## Broken Service Analysis

Analyseer waarom sommige services geen endpoints hebben:

```plain
echo "=== BROKEN SERVICE ENDPOINTS ==="
kubectl describe endpoints broken-service -n network || echo "Service may not exist"

echo "=== FAILING READINESS SERVICE ENDPOINTS ==="
kubectl describe endpoints failing-readiness-service -n network
```{{exec}}

## Service Selector vs Pod Labels

Controleer of service selectors matchen met pod labels:

```plain
echo "=== FRONTEND SERVICE SELECTOR ==="
kubectl get service frontend-service -n network -o jsonpath='{.spec.selector}' | jq .

echo "=== FRONTEND POD LABELS ==="
kubectl get pods -n network -l app=frontend -o jsonpath='{.items[*].metadata.labels}' | jq .
```{{exec}}

## Pod Readiness Status

Controleer waarom pods mogelijk niet ready zijn:

```plain
echo "=== POD READINESS STATUS ==="
kubectl get pods -n network -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase
```{{exec}}

## Failing Readiness Probe Analysis

Analyseer failing readiness probes:

```plain
echo "=== FAILING READINESS PROBE ANALYSIS ==="
kubectl get pods -n network -l app=failing-readiness

echo "Readiness probe configuration:"
kubectl get pods -n network -l app=failing-readiness -o yaml | grep -A 10 "readinessProbe:" | head -15
```{{exec}}

## Test Readiness Probe Manually

Test de readiness probe endpoint handmatig:

```plain
FAILING_POD_IP=$(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].status.podIP}')
echo "Testing readiness probe endpoint on $FAILING_POD_IP..."

echo "Testing failing endpoint /nonexistent:"
kubectl exec debug-pod -n network -- curl -s http://$FAILING_POD_IP/nonexistent || echo "❌ Probe endpoint faalt (verwacht)"

echo "Testing working endpoint /:"
kubectl exec debug-pod -n network -- curl -s http://$FAILING_POD_IP/ | head -2
```{{exec}}

## Fix Readiness Probe

Repareer de failing readiness probe:

```plain
echo "=== FIXING READINESS PROBE ==="
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
kubectl rollout status deployment/failing-readiness -n network --timeout=60s
```{{exec}}

## Validate Readiness Fix

Controleer of pods nu ready zijn:

```plain
echo "=== VALIDATING READINESS FIX ==="
kubectl get pods -n network -l app=failing-readiness

echo "Service endpoints after fix:"
kubectl get endpoints failing-readiness-service -n network
```{{exec}}

## Pod IP vs Endpoint IP Verification

Vergelijk pod IPs met endpoint IPs:

```plain
echo "=== POD IP vs ENDPOINT IP ==="
echo "Frontend pod IPs:"
kubectl get pods -n network -l app=frontend -o jsonpath='{.items[*].status.podIP}'

echo -e "\nFrontend endpoint IPs:"
kubectl get endpoints frontend-service -n network -o jsonpath='{.subsets[*].addresses[*].ip}'
```{{exec}}

## Service Port Mapping

Controleer port mapping tussen service en pods:

```plain
echo "=== SERVICE PORT MAPPING ==="
echo "Backend service ports:"
kubectl get service backend-service -n network -o jsonpath='{.spec.ports}' | jq .

echo "Backend pod ports:"
kubectl get pods -n network -l app=backend -o jsonpath='{.items[*].spec.containers[*].ports}' | jq .
```{{exec}}

## Direct Pod Connectivity Testing

Test directe pod connectivity:

```plain
echo "=== DIRECT POD CONNECTIVITY ==="
FRONTEND_POD_IP=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}')
echo "Testing direct access to frontend pod $FRONTEND_POD_IP:"
kubectl exec debug-pod -n network -- curl -s http://$FRONTEND_POD_IP | head -2

BACKEND_POD_IP=$(kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].status.podIP}')
echo "Testing direct access to backend pod $BACKEND_POD_IP:"
kubectl exec debug-pod -n network -- curl -s http://$BACKEND_POD_IP | head -2
```{{exec}}

## Service naar Pod Checklist

### ✅ **Service Has Endpoints**
- Service selector matcht pod labels
- Pods zijn running en ready
- Readiness probes slagen

### ✅ **Port Configuration**
- Service port is correct geconfigureerd
- Target port matcht pod container port
- Protocol is consistent

### ✅ **Pod Health**
- Pods zijn in Running status
- Readiness probes zijn correct geconfigureerd
- Pods hebben juiste labels

## Load Balancing Verification

Test load balancing tussen meerdere pods:

```plain
echo "=== LOAD BALANCING TEST ==="
for i in {1..3}; do
  echo "Request $i to frontend service:"
  kubectl exec debug-pod -n network -- curl -s http://frontend-service | grep -i "welcome\|nginx" | head -1
done
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Service naar Pod Troubleshooting

1. **Identificeer services zonder endpoints** en analyseer waarom
2. **Repareer readiness probe problemen** die endpoints blokkeren
3. **Valideer dat services correct naar pods routeren**

**Maak een Secret aan** met de naam `service-pod-test`:

```bash
kubectl create secret generic service-pod-test \
  --from-literal=service-without-endpoints="<service-zonder-endpoints>" \
  --from-literal=readiness-issue="<readiness-probe-probleem>" \
  --from-literal=fix-applied="<wat-je-hebt-gerepareerd>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je services zonder endpoints kunt identificeren
- ✅ Of je readiness probe problemen kunt diagnosticeren en repareren
- ✅ Of je service naar pod routing kunt valideren

**Tip**: Gebruik [`kubectl get endpoints -n network`](kubectl get endpoints -n network) om services zonder endpoints te vinden!

## Volgende Stap

Als services correct naar pods routeren, gaan we in de volgende stap de **complete end-to-end flow** testen!