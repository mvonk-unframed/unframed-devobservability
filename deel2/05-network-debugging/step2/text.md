# Stap 2: Ingress naar Service Debugging

## 🚪 Ingress Backend Validation

Nu de externe toegang naar ingress werkt, gaan we controleren of ingress correct routeert naar de backend services. Dit is waar veel routing problemen ontstaan.

## Ingress Backend Configuratie

Bekijk welke services de ingress gebruikt als backend:

```plain
echo "=== FRONTEND INGRESS BACKEND ==="
kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .
```{{exec}}

```plain
echo "=== API INGRESS BACKEND ==="
kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .
```{{exec}}

```plain
echo "=== BROKEN INGRESS BACKEND ==="
kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .
```{{exec}}

## Backend Service Validation

Controleer of de backend services bestaan:

```plain
echo "=== CHECKING BACKEND SERVICES ==="
kubectl get service frontend-service -n network || echo "❌ Frontend service missing"
kubectl get service backend-service -n network || echo "❌ Backend service missing"
kubectl get service nonexistent-service -n network || echo "❌ Nonexistent service missing (expected)"
```{{exec}}

## Service Port Matching

Controleer of ingress poorten matchen met service poorten:

```plain
echo "=== FRONTEND SERVICE PORTS ==="
kubectl get service frontend-service -n network -o jsonpath='{.spec.ports}' | jq .

echo "=== BACKEND SERVICE PORTS ==="
kubectl get service backend-service -n network -o jsonpath='{.spec.ports}' | jq .
```{{exec}}

## Ingress naar Service Testing

Test of ingress correct routeert naar services:

```plain
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "=== Testing Ingress to Service Routing ==="
echo "Frontend via ingress:"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -2

echo "API via ingress:"
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -2
```{{exec}}

## Direct Service Testing

Vergelijk met directe service toegang:

```plain
echo "=== Direct Service Access ==="
echo "Frontend direct:"
kubectl exec debug-pod -n network -- curl -s http://frontend-service | head -2

echo "Backend direct:"
kubectl exec debug-pod -n network -- curl -s http://backend-service:8080 | head -2
```{{exec}}

## Broken Ingress Analysis

Analyseer waarom de broken ingress faalt:

```plain
echo "=== BROKEN INGRESS ANALYSIS ==="
kubectl describe ingress broken-ingress -n network

echo "Testing broken ingress:"
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP || echo "Expected failure - backend service doesn't exist"
```{{exec}}

## Service Discovery van Ingress

Controleer of ingress de backend services kan vinden:

```plain
echo "=== SERVICE DISCOVERY FROM INGRESS NAMESPACE ==="
kubectl exec -n ingress-nginx $(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}') -- nslookup frontend-service.network.svc.cluster.local
```{{exec}}

## Ingress Controller Logs voor Backend Errors

Bekijk logs voor backend gerelateerde errors:

```plain
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=20 | grep -i "backend\|service\|upstream" || echo "No backend errors found"
```{{exec}}

## Fix Broken Ingress

Repareer de broken ingress door de backend service te corrigeren:

```plain
kubectl patch ingress broken-ingress -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/http/paths/0/backend/service/name",
    "value": "frontend-service"
  }
]'
```{{exec}}

## Validate Fix

Test de gerepareerde ingress:

```plain
echo "=== Testing Fixed Ingress ==="
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP | head -2
```{{exec}}

## Ingress naar Service Checklist

### ✅ **Backend Service Exists**
- Service is aanwezig in de juiste namespace
- Service naam in ingress is correct gespeld
- Service is niet in `Terminating` status

### ✅ **Port Configuration**
- Ingress backend port matcht service port
- Service port matcht pod target port
- Protocol (HTTP/HTTPS) is consistent

### ✅ **Service Accessibility**
- Service is bereikbaar vanuit ingress namespace
- DNS resolution werkt voor service
- Service heeft werkende endpoints

## Path-based Routing Testing

Test verschillende paths op de API ingress:

```plain
echo "=== PATH-BASED ROUTING TEST ==="
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api/health || echo "Path may not exist"
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Ingress naar Service Troubleshooting

1. **Identificeer de broken ingress** en analyseer de backend configuratie
2. **Controleer of backend services bestaan** en bereikbaar zijn
3. **Repareer de ingress configuratie** om naar een werkende service te wijzen

**Maak een Secret aan** met de naam `ingress-service-test`:

```bash
kubectl create secret generic ingress-service-test \
  --from-literal=broken-backend="<naam-van-broken-backend-service>" \
  --from-literal=working-backend="<naam-van-werkende-service>" \
  --from-literal=fix-applied="<wat-je-hebt-gerepareerd>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je ingress backend configuratie kunt analyseren
- ✅ Of je backend service problemen kunt identificeren
- ✅ Of je ingress configuratie kunt repareren

**Tip**: Gebruik [`kubectl describe ingress <name> -n network`](kubectl describe ingress) om backend configuratie te zien!

## Volgende Stap

Als ingress correct routeert naar services, gaan we in de volgende stap kijken naar **Service → Pod** connectivity!