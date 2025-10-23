# Stap 1: Ingress Analyse

## 🔍 Ingress Bekijken

In deze stap analyseren we de ingress configuratie om te controleren:
- Aan welke service is de ingress gekoppeld?
- Draait deze service?
- Wordt de juiste poort gebruikt?

*We gaan er vanuit dat de ingress controller al draait.*

## Ingress Resources Overzicht

Bekijk alle ingress resources in de network namespace:

```plain
kubectl get ingress -n network
```{{exec}}

Let op welke ingress resources er zijn en of ze een ADDRESS hebben.

## Ingress Configuratie Analyseren

Bekijk de configuratie van elke ingress:

```plain
echo "=== FRONTEND INGRESS ==="
kubectl describe ingress frontend-ingress -n network
```{{exec}}

```plain
echo "=== API INGRESS ==="
kubectl describe ingress api-ingress -n network
```{{exec}}

```plain
echo "=== BROKEN INGRESS ==="
kubectl describe ingress broken-ingress -n network
```{{exec}}

## Service Koppeling Controleren

Controleer aan welke services de ingress gekoppeld is:

```plain
echo "=== INGRESS BACKEND SERVICES ==="
echo "Frontend ingress backend:"
kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}'
echo

echo "API ingress backend:"
kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}'
echo

echo "Broken ingress backend:"
kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}'
echo
```{{exec}}

## Service Status Controleren

Controleer of de gekoppelde services bestaan en draaien:

```plain
echo "=== SERVICE STATUS CHECK ==="
kubectl get services -n network
```{{exec}}

Controleer specifiek de services die door ingress worden gebruikt:

```plain
echo "=== BACKEND SERVICE VALIDATION ==="
kubectl get service frontend-service -n network || echo "❌ Frontend service niet gevonden"
kubectl get service backend-service -n network || echo "❌ Backend service niet gevonden"
kubectl get service nonexistent-service -n network || echo "❌ Nonexistent service niet gevonden (verwacht)"
```{{exec}}

## Poort Configuratie Controleren

Controleer of de poorten in ingress matchen met de service poorten:

```plain
echo "=== POORT CONFIGURATIE ==="
echo "Frontend ingress poort:"
kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}'
echo

echo "Frontend service poorten:"
kubectl get service frontend-service -n network -o jsonpath='{.spec.ports[*].port}'
echo

echo "API ingress poort:"
kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}'
echo

echo "Backend service poorten:"
kubectl get service backend-service -n network -o jsonpath='{.spec.ports[*].port}'
echo
```{{exec}}

## Ingress Connectiviteit Testen

Test of de ingress correct werkt:

```plain
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')

echo "=== INGRESS CONNECTIVITEIT TEST ==="
echo "Ingress controller IP: $INGRESS_IP"

echo "Testing frontend ingress:"
kubectl run --rm -it debug-pod -n network --image=curlimages/curl -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -2

echo "Testing API ingress:"
kubectl run --rm -it debug-pod2 -n network --image=curlimages/curl -- curl -s -H "Host: api.local" http://$INGRESS_IP/api | head -2

echo "Testing broken ingress:"
kubectl run --rm -it debug-pod3 -n network --image=curlimages/curl -- curl -s -H "Host: broken.local" http://$INGRESS_IP || echo "❌ Broken ingress faalt (verwacht)"
```{{exec}}

## Ingress Analyse Checklist

### ✅ **Service Koppeling**
- Ingress wijst naar bestaande service
- Service naam is correct gespeld
- Service bestaat in juiste namespace

### ✅ **Poort Configuratie**
- Ingress backend poort matcht service poort
- Service luistert op de juiste poort
- Geen poort mismatches

### ✅ **Connectiviteit**
- Ingress reageert op requests
- Juiste Host headers worden gebruikt
- Geen 404 of 502 errors van ingress

## 🎯 Praktische Opdracht

### Opdracht: Ingress Service Koppeling Analyseren

1. **Identificeer welke service** elke ingress gebruikt als backend
2. **Controleer of deze services bestaan** en draaien
3. **Valideer poort configuratie** tussen ingress en service

**Maak een Secret aan** met de naam `ingress-analysis`:

```bash
kubectl create secret generic ingress-analysis \
  --from-literal=broken-service="<naam-van-missing-service>" \
  --from-literal=working-service="<naam-van-werkende-service>" \
  --from-literal=port-mismatch="<ja/nee>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je ingress backend configuratie kunt analyseren
- ✅ Of je service koppeling problemen kunt identificeren
- ✅ Of je poort configuratie kunt valideren

**Tip**: Gebruik [`kubectl describe ingress <name> -n network`](kubectl describe ingress) om backend details te zien!

## Volgende Stap

Nu we de ingress configuratie hebben geanalyseerd, gaan we in de volgende stap kijken naar de **Service configuratie**!