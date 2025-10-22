# Stap 1: Extern naar Ingress Debugging

## 🌐 External Access Troubleshooting

De eerste stap in network debugging is controleren of externe traffic de ingress controller kan bereiken. Dit is waar de meeste "website niet bereikbaar" problemen beginnen.

## Ingress Controller Status Controleren

Controleer eerst of de ingress controller draait:

```plain
kubectl get pods -n ingress-nginx
```{{exec}}

Alle ingress controller pods moeten `Running` en `Ready` zijn.

## Ingress Controller Service

Bekijk de ingress controller service:

```plain
kubectl get services -n ingress-nginx
```{{exec}}

Let op de service type en poorten. Voor externe toegang heb je meestal een `NodePort` of `LoadBalancer` service nodig.

## Ingress Resources Bekijken

Bekijk alle ingress resources in de network namespace:

```plain
kubectl get ingress -n network
```{{exec}}

Controleer of er ingress resources zijn en of ze een ADDRESS hebben.

## Ingress Configuratie Analyseren

Bekijk de frontend ingress configuratie:

```plain
kubectl describe ingress frontend-ingress -n network
```{{exec}}

Let op:
- **Host**: Welke hostname wordt verwacht?
- **Backend**: Naar welke service wordt gerouteerd?
- **Address**: Heeft de ingress een IP adres?

## Broken Ingress Identificeren

Bekijk de broken ingress:

```plain
kubectl describe ingress broken-ingress -n network
```{{exec}}

Wat zie je dat anders is dan bij de werkende ingress?

## External Access Testing

Test externe toegang via de ingress controller:

```plain
# Haal ingress controller IP op
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')
echo "Ingress controller IP: $INGRESS_IP"

# Test frontend toegang met juiste Host header
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP
```{{exec}}

## Host Header Importance

Ingress gebruikt Host headers voor routing. Test zonder Host header:

```plain
kubectl exec debug-pod -n network -- curl -s http://$INGRESS_IP
```{{exec}}

Vergelijk met de juiste Host header:

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP
```{{exec}}

## Ingress Controller Logs

Bekijk ingress controller logs voor errors:

```plain
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=10
```{{exec}}

Zoek naar errors gerelateerd aan backend services of routing.

## Multiple Ingress Testing

Test verschillende ingress endpoints:

```plain
echo "=== Testing Frontend Ingress ==="
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -3

echo "=== Testing API Ingress ==="
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -3

echo "=== Testing Broken Ingress ==="
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP || echo "Expected failure"
```{{exec}}

## Ingress Events

Bekijk events gerelateerd aan ingress resources:

```plain
kubectl get events -n network --field-selector involvedObject.kind=Ingress
```{{exec}}

## Extern naar Ingress Checklist

### ✅ **Ingress Controller**
- Controller pods zijn running
- Controller service is accessible
- Logs tonen geen kritieke errors

### ✅ **Ingress Configuration**
- Ingress resource bestaat
- Host configuratie is correct
- Backend service is gespecificeerd

### ✅ **External Access**
- Juiste Host headers worden gebruikt
- HTTP response wordt ontvangen
- Geen 404 of 502 errors

## 🎯 Praktische Opdracht

### Opdracht: Extern naar Ingress Troubleshooting

1. **Identificeer de broken ingress** die niet werkt
2. **Test externe toegang** met verschillende Host headers
3. **Analyseer ingress controller logs** voor errors

**Maak een Secret aan** met de naam `ingress-external-test`:

```bash
kubectl create secret generic ingress-external-test \
  --from-literal=working-ingress="<werkende-ingress-naam>" \
  --from-literal=broken-ingress="<broken-ingress-naam>" \
  --from-literal=ingress-controller-status="running/failing"
```

### Verificatie

De verificatie controleert:
- ✅ Of je ingress controller status kunt controleren
- ✅ Of je externe toegang kunt testen met Host headers
- ✅ Of je broken ingress kunt identificeren

**Tip**: Gebruik [`kubectl get ingress -n network`](kubectl get ingress -n network) om alle ingress resources te zien!

## Volgende Stap

Als externe toegang naar ingress werkt, gaan we in de volgende stap kijken naar **Ingress → Service** routing!