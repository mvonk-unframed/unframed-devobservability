# Stap 5: Network Troubleshooting Scenario

## Praktische Network Debugging Oefening

Nu ga je alle geleerde technieken toepassen op een complete network troubleshooting scenario. Er is een probleem gemeld: "De website is niet bereikbaar en de API geeft errors!"

## Scenario: Complete Network Outage

### Stap 1: Initial Assessment

Bekijk de overall status van alle network resources:

```plain
kubectl get all -n network
```{{exec}}

```plain
kubectl get ingress -n network
```{{exec}}

### Stap 2: Service Discovery Check

Test of services bereikbaar zijn via DNS:

```plain
echo "=== DNS RESOLUTION TEST ==="
for service in frontend-service backend-service database-service; do
  echo "Testing $service..."
  kubectl exec debug-pod -n network -- nslookup $service.network.svc.cluster.local
done
```{{exec}}

### Stap 3: Service Endpoint Validation

Controleer welke services endpoints hebben:

```plain
echo "=== SERVICE ENDPOINTS STATUS ==="
kubectl get endpoints -n network
```{{exec}}

Identificeer services zonder endpoints:

```plain
kubectl get endpoints -n network | grep "<none>" || echo "Alle services hebben endpoints"
```{{exec}}

### Stap 4: Pod Readiness Analysis

Analyseer waarom pods mogelijk niet ready zijn:

```plain
echo "=== POD READINESS STATUS ==="
kubectl get pods -n network -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase
```{{exec}}

Bekijk failing readiness pods in detail:

```plain
kubectl describe pod -n network -l app=failing-readiness | grep -A 15 "Conditions:"
```{{exec}}

### Stap 5: Connectivity Flow Testing

Test de complete connectivity flow: Client → Ingress → Service → Pod

```plain
echo "=== COMPLETE CONNECTIVITY FLOW TEST ==="

# 1. Test ingress controller
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')
echo "Ingress IP: $INGRESS_IP"

# 2. Test frontend via ingress
echo "Testing frontend via ingress..."
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -5

# 3. Test API via ingress
echo "Testing API via ingress..."
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -5

# 4. Test direct service connectivity
echo "Testing direct service connectivity..."
kubectl exec debug-pod -n network -- curl -s http://frontend-service | head -5
```{{exec}}

### Stap 6: Database Connectivity Deep Dive

Test database connectivity en troubleshoot eventuele problemen:

```plain
echo "=== DATABASE CONNECTIVITY TEST ==="

# Test port connectivity
kubectl exec debug-pod -n network -- nc -zv database-service 5432

# Test database readiness
kubectl get pods -n network -l app=database

# Check database logs
kubectl logs -n network -l app=database --tail=10
```{{exec}}

### Stap 7: Readiness Probe Troubleshooting

Analyseer en los readiness probe problemen op:

```plain
echo "=== READINESS PROBE ANALYSIS ==="

# Bekijk failing readiness probe configuratie
kubectl get pods -n network -l app=failing-readiness -o yaml | grep -A 10 "readinessProbe:"

# Test de probe endpoint handmatig
FAILING_POD_IP=$(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].status.podIP}')
echo "Testing readiness probe endpoint on $FAILING_POD_IP..."
kubectl exec debug-pod -n network -- curl -s http://$FAILING_POD_IP/nonexistent || echo "Probe endpoint faalt (verwacht)"

# Test werkende endpoint
kubectl exec debug-pod -n network -- curl -s http://$FAILING_POD_IP/ | head -3
```{{exec}}

### Stap 8: Fix Readiness Probe

Repareer de failing readiness probe:

```plain
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

Controleer of pods nu ready zijn:

```plain
kubectl get pods -n network -l app=failing-readiness
```{{exec}}

### Stap 9: End-to-End Connectivity Validation

Test de complete applicatie stack na fixes:

```plain
echo "=== END-TO-END CONNECTIVITY VALIDATION ==="

# Test alle ingress endpoints
for host in frontend.local api.local broken.local; do
  echo "Testing $host..."
  kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: $host" http://$INGRESS_IP | head -2
done
```{{exec}}

### Stap 10: Performance en Load Testing

Test load balancing en performance:

```plain
echo "=== LOAD BALANCING TEST ==="

# Test meerdere requests naar frontend
for i in {1..5}; do
  echo "Request $i to frontend:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | grep -i "welcome\|nginx" | head -1
done

# Test backend load balancing
for i in {1..3}; do
  echo "Request $i to backend:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -1
done
```{{exec}}

### Stap 11: Network Monitoring

Monitor network events en logs:

```plain
echo "=== NETWORK MONITORING ==="

# Recent network events
kubectl get events -n network --sort-by=.metadata.creationTimestamp --tail=10

# Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=5
```{{exec}}

### Stap 12: Complete Health Check

Voer een complete health check uit van alle network components:

```plain
echo "=== COMPLETE NETWORK HEALTH CHECK ==="

echo "1. Namespace status:"
kubectl get namespace network

echo "2. Pod status:"
kubectl get pods -n network

echo "3. Service status:"
kubectl get services -n network

echo "4. Endpoint status:"
kubectl get endpoints -n network

echo "5. Ingress status:"
kubectl get ingress -n network

echo "6. Ingress controller status:"
kubectl get pods -n ingress-nginx

echo "=== HEALTH CHECK SUMMARY ==="
TOTAL_PODS=$(kubectl get pods -n network --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -n network --no-headers | grep "Running" | wc -l)
READY_PODS=$(kubectl get pods -n network --no-headers | grep "1/1\|2/2" | wc -l)

echo "Total pods: $TOTAL_PODS"
echo "Running pods: $RUNNING_PODS"
echo "Ready pods: $READY_PODS"

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$READY_PODS" -gt 0 ]; then
  echo "✅ Network health check PASSED"
else
  echo "⚠️ Some network issues detected"
fi
```{{exec}}

## Network Debugging Mastery Checklist

### ✅ **Service Discovery**
- DNS resolution werkt voor alle services
- Service selectors matchen pod labels
- Endpoints worden correct gegenereerd

### ✅ **Connectivity**
- Pod-to-service communication werkt
- Cross-namespace connectivity werkt
- Direct pod-to-pod communication werkt

### ✅ **Load Balancing**
- Services distribueren traffic correct
- Ingress routeert naar juiste backends
- NodePort services zijn toegankelijk

### ✅ **Health Checks**
- Readiness probes zijn correct geconfigureerd
- Liveness probes voorkomen zombie pods
- Health check endpoints zijn bereikbaar

### ✅ **External Access**
- Ingress controller is operationeel
- Host-based routing werkt
- Path-based routing werkt
- TLS termination werkt (indien geconfigureerd)

## Troubleshooting Workflow Samenvatting

1. **🔍 Identify**: Welke component faalt?
2. **📋 Analyze**: Service → Endpoints → Pods → Probes
3. **🔗 Test**: DNS → Service → Pod connectivity
4. **🌐 Validate**: Ingress → Service → Pod flow
5. **🔧 Fix**: Repareer configuratie issues
6. **✅ Verify**: End-to-end connectivity test

**Gefeliciteerd! Je hebt een complete network troubleshooting scenario succesvol doorlopen!**