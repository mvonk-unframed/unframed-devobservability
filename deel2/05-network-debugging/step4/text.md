# Stap 4: End-to-End Flow Debugging

## 🔄 Complete Network Flow Validation

Nu alle individuele componenten werken, gaan we de complete flow testen: **Extern → Ingress → Service → Pod**. Dit is waar je valideert dat alles samen werkt.

## Complete Flow Overview

Test de complete network flow stap voor stap:

```plain
echo "=== COMPLETE NETWORK FLOW TEST ==="

# 1. Ingress Controller Status
echo "1. Ingress Controller Status:"
kubectl get pods -n ingress-nginx | grep controller

# 2. Ingress Resources
echo "2. Ingress Resources:"
kubectl get ingress -n network

# 3. Services Status
echo "3. Services Status:"
kubectl get services -n network

# 4. Endpoints Status
echo "4. Endpoints Status:"
kubectl get endpoints -n network
```{{exec}}

## End-to-End Connectivity Testing

Test de complete flow voor elke applicatie:

```plain
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "=== END-TO-END CONNECTIVITY TEST ==="
echo "Ingress IP: $INGRESS_IP"

echo "Testing Frontend (extern → ingress → service → pod):"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -2

echo "Testing API (extern → ingress → service → pod):"
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -2

echo "Testing Fixed Broken App:"
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP | head -2
```{{exec}}

## Flow Comparison: Ingress vs Direct

Vergelijk ingress toegang met directe service toegang:

```plain
echo "=== FLOW COMPARISON ==="

echo "Via Ingress (complete flow):"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -1

echo "Direct Service (bypassing ingress):"
kubectl exec debug-pod -n network -- curl -s http://frontend-service | head -1

echo "Direct Pod (bypassing service):"
POD_IP=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}')
kubectl exec debug-pod -n network -- curl -s http://$POD_IP | head -1
```{{exec}}

## Load Balancing Validation

Test load balancing door de complete flow:

```plain
echo "=== LOAD BALANCING THROUGH COMPLETE FLOW ==="

for i in {1..5}; do
  echo "Request $i via complete flow:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | grep -i "welcome\|nginx" | head -1
done
```{{exec}}

## Performance Testing

Test response times door de complete flow:

```plain
echo "=== PERFORMANCE TESTING ==="

echo "Response time via ingress:"
kubectl exec debug-pod -n network -- time curl -s -H "Host: frontend.local" http://$INGRESS_IP >/dev/null

echo "Response time direct service:"
kubectl exec debug-pod -n network -- time curl -s http://frontend-service >/dev/null
```{{exec}}

## Error Scenario Testing

Test hoe de flow reageert op verschillende failure scenarios:

```plain
echo "=== ERROR SCENARIO TESTING ==="

echo "Testing non-existent host:"
kubectl exec debug-pod -n network -- curl -s -H "Host: nonexistent.local" http://$INGRESS_IP || echo "Expected 404"

echo "Testing wrong path:"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP/nonexistent || echo "Expected 404"

echo "Testing service without endpoints:"
kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://failing-readiness-service || echo "Expected timeout/error"
```{{exec}}

## Health Check Validation

Voer een complete health check uit:

```plain
echo "=== COMPLETE HEALTH CHECK ==="

echo "1. Namespace status:"
kubectl get namespace network

echo "2. Pod health:"
kubectl get pods -n network -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[*].ready

echo "3. Service health:"
kubectl get services -n network -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP

echo "4. Endpoint health:"
kubectl get endpoints -n network -o custom-columns=NAME:.metadata.name,ENDPOINTS:.subsets[*].addresses[*].ip

echo "5. Ingress health:"
kubectl get ingress -n network -o custom-columns=NAME:.metadata.name,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[*].ip
```{{exec}}

## Network Flow Troubleshooting Matrix

Test systematisch elke stap van de flow:

```plain
echo "=== NETWORK FLOW TROUBLESHOOTING MATRIX ==="

# Test 1: External → Ingress
echo "Test 1: External → Ingress"
kubectl get service ingress-nginx-controller -n ingress-nginx && echo "✅ Ingress accessible" || echo "❌ Ingress not accessible"

# Test 2: Ingress → Service
echo "Test 2: Ingress → Service"
kubectl get service frontend-service -n network && echo "✅ Service exists" || echo "❌ Service missing"

# Test 3: Service → Pod
echo "Test 3: Service → Pod"
ENDPOINTS=$(kubectl get endpoints frontend-service -n network -o jsonpath='{.subsets[*].addresses[*].ip}')
if [ -n "$ENDPOINTS" ]; then
  echo "✅ Service has endpoints: $ENDPOINTS"
else
  echo "❌ Service has no endpoints"
fi

# Test 4: Pod Health
echo "Test 4: Pod Health"
kubectl get pods -n network -l app=frontend | grep Running && echo "✅ Pods running" || echo "❌ Pods not running"
```{{exec}}

## Complete Flow Debugging Checklist

### ✅ **External Access**
- Ingress controller is running
- External IP/port is accessible
- DNS resolution works (if applicable)

### ✅ **Ingress Layer**
- Ingress resources exist
- Host/path rules are correct
- Backend services are specified

### ✅ **Service Layer**
- Services exist and are accessible
- Service selectors match pod labels
- Port configuration is correct

### ✅ **Pod Layer**
- Pods are running and ready
- Readiness probes pass
- Application is responding

## Monitoring and Observability

Monitor de complete flow:

```plain
echo "=== MONITORING COMPLETE FLOW ==="

echo "Recent events across all components:"
kubectl get events -n network --sort-by=.metadata.creationTimestamp --tail=10

echo "Ingress controller logs:"
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=5

echo "Application logs:"
kubectl logs -n network -l app=frontend --tail=3
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: End-to-End Flow Validation

1. **Test de complete flow** van extern naar pod voor alle applicaties
2. **Identificeer en repareer** eventuele flow onderbrekingen
3. **Valideer load balancing** door de complete flow

**Maak een Secret aan** met de naam `end-to-end-test`:

```bash
kubectl create secret generic end-to-end-test \
  --from-literal=frontend-flow="working/broken" \
  --from-literal=api-flow="working/broken" \
  --from-literal=load-balancing="working/broken"
```

### Verificatie

De verificatie controleert:
- ✅ Of je de complete network flow kunt testen
- ✅ Of je flow onderbrekingen kunt identificeren en repareren
- ✅ Of je end-to-end connectivity kunt valideren

**Tip**: Test systematisch elke stap: Extern → Ingress → Service → Pod!

## Volgende Stap

Nu je de complete flow begrijpt, gaan we in de volgende stap een **praktische troubleshooting scenario** doorlopen!