# Stap 4: Praktische Troubleshooting Oefening

## 🚨 Scenario: Website Down!

Je krijgt een melding: **"De website is niet bereikbaar!"**

Gebruik de geleerde technieken om systematisch te debuggen volgens de drie stappen:
1. **Ingress bekijken** - service koppeling, poorten
2. **Service bekijken** - labels, pods, poorten
3. **Pod bekijken** - status, readiness

## Stap 1: Ingress Diagnose

Controleer de ingress configuratie:

```plain
echo "=== STAP 1: INGRESS DIAGNOSE ==="
echo "1. Ingress overzicht:"
kubectl get ingress -n network

echo "2. Ingress backend services:"
kubectl get ingress -n network -o custom-columns=NAME:.metadata.name,SERVICE:.spec.rules[*].http.paths[*].backend.service.name,PORT:.spec.rules[*].http.paths[*].backend.service.port.number

echo "3. Service status check:"
kubectl get services -n network
```{{exec}}

Test ingress connectiviteit:

```plain
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "=== INGRESS CONNECTIVITEIT TEST ==="
echo "Testing frontend via ingress:"
kubectl run --rm -it debug-pod -n network --image=curlimages/curl -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -1

echo "Testing broken ingress:"
kubectl run --rm -it debug-pod2 -n network --image=curlimages/curl -- curl -s -H "Host: broken.local" http://$INGRESS_IP || echo "❌ Broken ingress faalt"
```{{exec}}

## Stap 2: Service Diagnose

Controleer service configuratie en endpoints:

```plain
echo "=== STAP 2: SERVICE DIAGNOSE ==="
echo "1. Service selectors:"
kubectl get services -n network -o custom-columns=NAME:.metadata.name,SELECTOR:.spec.selector

echo "2. Service endpoints:"
kubectl get endpoints -n network

echo "3. Services zonder endpoints:"
kubectl get endpoints -n network | grep "<none>" && echo "❌ Services zonder endpoints gevonden" || echo "✅ Alle services hebben endpoints"
```{{exec}}

Test directe service toegang:

```plain
echo "=== SERVICE CONNECTIVITEIT TEST ==="
echo "Testing frontend service direct:"
kubectl run --rm -it debug-pod3 -n network --image=curlimages/curl -- curl -s http://frontend-service | head -1

echo "Testing failing readiness service:"
kubectl run --rm -it debug-pod4 -n network --image=curlimages/curl -- curl -s --connect-timeout 5 http://failing-readiness-service || echo "❌ Service heeft geen endpoints"
```{{exec}}

## Stap 3: Pod Diagnose

Controleer pod status en readiness:

```plain
echo "=== STAP 3: POD DIAGNOSE ==="
echo "1. Pod status overzicht:"
kubectl get pods -n network -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[*].ready

echo "2. Pods die niet ready zijn:"
kubectl get pods -n network | grep "0/" && echo "❌ Not ready pods gevonden" || echo "✅ Alle pods zijn ready"

echo "3. Readiness probe configuratie:"
kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].spec.containers[0].readinessProbe}' | jq .
```{{exec}}

Test pod readiness probe:

```plain
echo "=== POD READINESS PROBE TEST ==="
FAILING_POD_IP=$(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].status.podIP}')
echo "Testing failing readiness probe endpoint:"
kubectl run --rm -it debug-pod5 -n network --image=curlimages/curl -- curl -s --connect-timeout 3 http://$FAILING_POD_IP/nonexistent || echo "❌ Probe endpoint faalt"

echo "Testing working endpoint:"
kubectl run --rm -it debug-pod6 -n network --image=curlimages/curl -- curl -s http://$FAILING_POD_IP/ | head -1
```{{exec}}

## Problemen Repareren

Pas de gevonden problemen toe:

```plain
echo "=== PROBLEMEN REPAREREN ==="
echo "1. Fix broken ingress backend service:"
kubectl patch ingress broken-ingress -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/http/paths/0/backend/service/name",
    "value": "frontend-service"
  }
]'

echo "2. Fix failing readiness probe:"
kubectl patch deployment failing-readiness -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/path",
    "value": "/"
  }
]'
```{{exec}}

Wacht op deployment rollout:

```plain
echo "Wachten op deployment rollout..."
kubectl rollout status deployment/failing-readiness -n network --timeout=60s
```{{exec}}

## End-to-End Validatie

Test de complete flow na reparaties:

```plain
echo "=== END-TO-END VALIDATIE ==="
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "1. Frontend flow test:"
kubectl run --rm -it debug-pod7 -n network --image=curlimages/curl -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -1

echo "2. API flow test:"
kubectl run --rm -it debug-pod8 -n network --image=curlimages/curl -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -1

echo "3. Fixed broken app test:"
kubectl run --rm -it debug-pod9 -n network --image=curlimages/curl -- curl -s -H "Host: broken.local" http://$INGRESS_IP | head -1

echo "4. Service endpoints na fix:"
kubectl get endpoints -n network
```{{exec}}

## Troubleshooting Checklist

### ✅ **Ingress Laag**
- Ingress wijst naar bestaande service
- Service naam is correct
- Poort configuratie klopt

### ✅ **Service Laag**
- Service selector matcht pod labels
- Service heeft endpoints
- Poort doorsturen is correct

### ✅ **Pod Laag**
- Pods zijn running en ready
- Readiness probes slagen
- Applicatie reageert

## 🎯 Praktische Opdracht

### Opdracht: Complete Network Troubleshooting

1. **Volg de drie stappen systematisch** om problemen te identificeren
2. **Repareer alle gevonden problemen**
3. **Valideer dat de complete flow werkt**

**Maak een Secret aan** met je bevindingen:

```bash
kubectl create secret generic network-troubleshooting \
  --from-literal=ingress-problem="<ingress-probleem-gevonden>" \
  --from-literal=service-problem="<service-probleem-gevonden>" \
  --from-literal=pod-problem="<pod-probleem-gevonden>" \
  --from-literal=all-fixed="<ja/nee>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je systematisch kunt troubleshooten volgens de drie stappen
- ✅ Of je problemen kunt identificeren en repareren
- ✅ Of je end-to-end connectivity kunt valideren

**Tip**: Volg altijd de volgorde: Ingress → Service → Pod!

## 🏆 Gefeliciteerd!

Je hebt geleerd om systematisch network problemen te debuggen:
- ✅ **Ingress analyse**: Service koppeling en poorten controleren
- ✅ **Service analyse**: Labels, pods en poort doorsturen controleren
- ✅ **Pod analyse**: Status en readiness controleren
- ✅ **Problemen repareren**: Configuratie fixes toepassen
- ✅ **End-to-end validatie**: Complete flow testen

Deze systematische aanpak helpt je om snel network problemen op te lossen in Kubernetes!