# Stap 5: Praktische Oefening

## 🚨 Scenario: Website Down!

Je krijgt een melding: **"De website is niet bereikbaar!"**

Gebruik de geleerde technieken om systematisch te debuggen: **Extern → Ingress → Service → Pod**

## Quick Assessment

Bekijk de overall status:

```plain
kubectl get all -n network
kubectl get ingress -n network
```{{exec}}

## Systematic Debugging

Test elke stap van de flow:

```plain
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "=== TESTING COMPLETE FLOW ==="
echo "1. External → Ingress:"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -1

echo "2. Direct Service:"
kubectl exec debug-pod -n network -- curl -s http://frontend-service | head -1

echo "3. Service Endpoints:"
kubectl get endpoints -n network | grep frontend-service
```{{exec}}

## Find and Fix Problems

Identificeer problemen:

```plain
echo "=== FINDING PROBLEMS ==="
kubectl get endpoints -n network | grep "<none>" && echo "❌ Services without endpoints found"
kubectl get pods -n network | grep "0/" && echo "❌ Pods not ready found"
```{{exec}}

Fix de problemen:

```plain
echo "=== APPLYING FIXES ==="
# Fix broken ingress
kubectl patch ingress broken-ingress -n network --type='json' -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value": "frontend-service"}]'

# Fix readiness probe
kubectl patch deployment failing-readiness -n network --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/path", "value": "/"}]'
```{{exec}}

## Validate Fix

Test dat alles werkt:

```plain
echo "=== VALIDATION ==="
for host in frontend.local api.local broken.local; do
  echo "Testing $host:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: $host" http://$INGRESS_IP | head -1
done
```{{exec}}

## 🎯 Opdracht

**Maak een Secret aan** met je bevindingen:

```bash
kubectl create secret generic network-debug-report \
  --from-literal=problem-found="<wat-was-het-probleem>" \
  --from-literal=fix-applied="<hoe-heb-je-het-opgelost>" \
  --from-literal=status="resolved"
```

## 🏆 Gefeliciteerd!

Je hebt geleerd om systematisch network problemen te debuggen:
- ✅ **Flow volgen**: Extern → Ingress → Service → Pod
- ✅ **Problemen identificeren**: Endpoints, readiness probes, configuratie
- ✅ **Fixes toepassen**: Patches en configuratie updates
- ✅ **Valideren**: End-to-end connectivity testen