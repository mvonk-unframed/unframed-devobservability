# Stap 2: Service Analyse

## 🔍 Service Bekijken

In deze stap analyseren we de service configuratie om te controleren:
- Welke labels worden gebruikt voor pod selectie?
- Welke pods voldoen aan deze labels?
- Welke poort wordt doorgestuurd naar de pods?

## Service Overzicht

Bekijk alle services in de network namespace:

```plain
kubectl get services -n network
```{{exec}}

Bekijk de services in detail:

```plain
echo "=== SERVICE DETAILS ==="
kubectl describe service frontend-service -n network
```{{exec}}

```plain
kubectl describe service backend-service -n network
```{{exec}}

```plain
kubectl describe service failing-readiness-service -n network
```{{exec}}

## Service Selectors Analyseren

Controleer welke labels elke service gebruikt om pods te selecteren:

```plain
echo "=== SERVICE SELECTORS ==="
echo "Frontend service selector:"
kubectl get service frontend-service -n network -o jsonpath='{.spec.selector}' | jq .

echo "Backend service selector:"
kubectl get service backend-service -n network -o jsonpath='{.spec.selector}' | jq .

echo "Failing readiness service selector:"
kubectl get service failing-readiness-service -n network -o jsonpath='{.spec.selector}' | jq .
```{{exec}}

## Pod Labels Controleren

Controleer welke pods voldoen aan de service selectors:

```plain
echo "=== PODS MATCHING SERVICE SELECTORS ==="
echo "Pods met label app=frontend:"
kubectl get pods -n network -l app=frontend --show-labels

echo "Pods met label app=backend:"
kubectl get pods -n network -l app=backend --show-labels

echo "Pods met label app=failing-readiness:"
kubectl get pods -n network -l app=failing-readiness --show-labels
```{{exec}}

## Service Endpoints Controleren

Bekijk welke pod IPs de services als endpoints hebben:

```plain
echo "=== SERVICE ENDPOINTS ==="
kubectl get endpoints -n network
```{{exec}}

Analyseer endpoints in detail:

```plain
echo "=== ENDPOINT DETAILS ==="
echo "Frontend service endpoints:"
kubectl describe endpoints frontend-service -n network

echo "Backend service endpoints:"
kubectl describe endpoints backend-service -n network

echo "Failing readiness service endpoints:"
kubectl describe endpoints failing-readiness-service -n network
```{{exec}}

## Poort Doorsturen Analyseren

Controleer hoe services poorten doorsturen naar pods:

```plain
echo "=== POORT DOORSTUREN ==="
echo "Frontend service poorten:"
kubectl get service frontend-service -n network -o jsonpath='{.spec.ports}' | jq .

echo "Frontend pod poorten:"
kubectl get pods -n network -l app=frontend -o jsonpath='{.items[*].spec.containers[*].ports}' | jq .

echo "Backend service poorten:"
kubectl get service backend-service -n network -o jsonpath='{.spec.ports}' | jq .

echo "Backend pod poorten:"
kubectl get pods -n network -l app=backend -o jsonpath='{.items[*].spec.containers[*].ports}' | jq .
```{{exec}}

## Service Connectiviteit Testen

Test directe service toegang:

```plain
echo "=== SERVICE CONNECTIVITEIT TEST ==="
echo "Testing frontend service:"
kubectl run --rm -it debug-pod -n network --image=curlimages/curl -- curl -s http://frontend-service | head -2

echo "Testing backend service:"
kubectl run --rm -it debug-pod2 -n network --image=curlimages/curl -- curl -s http://backend-service:8080 | head -2

echo "Testing failing readiness service:"
kubectl run --rm -it debug-pod3 -n network --image=curlimages/curl -- curl -s --connect-timeout 5 http://failing-readiness-service || echo "❌ Service heeft geen endpoints"
```{{exec}}

## Probleem Identificatie

Identificeer services zonder endpoints:

```plain
echo "=== SERVICES ZONDER ENDPOINTS ==="
kubectl get endpoints -n network | grep "<none>" && echo "❌ Services zonder endpoints gevonden" || echo "✅ Alle services hebben endpoints"
```{{exec}}

## Service Analyse Checklist

### ✅ **Label Matching**
- Service selector matcht pod labels
- Pods hebben de juiste labels
- Geen typos in label namen

### ✅ **Pod Beschikbaarheid**
- Pods zijn running
- Pods zijn ready (readiness probes slagen)
- Pods hebben de juiste labels

### ✅ **Poort Configuratie**
- Service port is correct
- Target port matcht pod container port
- Protocol is consistent (TCP/UDP)

## 🎯 Praktische Opdracht

### Opdracht: Service Label en Poort Analyse

1. **Identificeer welke labels** elke service gebruikt voor pod selectie
2. **Controleer welke pods** voldoen aan deze labels
3. **Analyseer poort doorsturen** van service naar pods

**Maak een Secret aan** met de naam `service-analysis`:

```bash
kubectl create secret generic service-analysis \
  --from-literal=service-without-endpoints="<service-zonder-endpoints>" \
  --from-literal=label-mismatch="<ja/nee>" \
  --from-literal=port-mismatch="<ja/nee>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je service selectors kunt analyseren
- ✅ Of je pod label matching kunt controleren
- ✅ Of je poort configuratie kunt valideren

**Tip**: Gebruik [`kubectl get endpoints -n network`](kubectl get endpoints -n network) om services zonder endpoints te vinden!

## Volgende Stap

Nu we de service configuratie hebben geanalyseerd, gaan we in de volgende stap kijken naar de **Pod status en readiness**!