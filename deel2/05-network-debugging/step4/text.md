# Stap 4: Ingress en Load Balancer Debugging

## Ingress Concept Begrijpen

Ingress beheert externe toegang tot services in een cluster, typisch HTTP/HTTPS. Het fungeert als een reverse proxy en load balancer.

## Bekijk Alle Ingress Resources

```plain
kubectl get ingress -n network
```{{exec}}

Bekijk gedetailleerde informatie:

```plain
kubectl get ingress -n network -o wide
```{{exec}}

## Ingress Controller Status

Controleer of de ingress controller draait:

```plain
kubectl get pods -n ingress-nginx
```{{exec}}

```plain
kubectl get services -n ingress-nginx
```{{exec}}

## Werkende Ingress Analyseren

Bekijk de frontend ingress configuratie:

```plain
kubectl describe ingress frontend-ingress -n network
```{{exec}}

## Broken Ingress Analyseren

Bekijk de broken ingress:

```plain
kubectl describe ingress broken-ingress -n network
```{{exec}}

Let op de backend service - bestaat deze?

```plain
kubectl get service nonexistent-service -n network || echo "Service bestaat niet (verwacht)"
```{{exec}}

## Ingress Backend Validation

Controleer of ingress backends geldig zijn:

```plain
echo "=== FRONTEND INGRESS BACKEND ==="
kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .
```{{exec}}

```plain
echo "=== BROKEN INGRESS BACKEND ==="
kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .
```{{exec}}

## Ingress Controller Logs

Bekijk ingress controller logs voor errors:

```plain
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=20
```{{exec}}

## External Access Testing

Test externe toegang via ingress (simulatie):

```plain
# Haal ingress controller service IP op
INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')
echo "Ingress controller IP: $INGRESS_IP"

# Test frontend ingress
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP
```{{exec}}

## API Ingress Testing

Test de API ingress:

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api
```{{exec}}

## Broken Ingress Testing

Test de broken ingress (zou moeten falen):

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP || echo "Verwachte fout: backend service bestaat niet"
```{{exec}}

## Ingress Events Bekijken

Bekijk events gerelateerd aan ingress:

```plain
kubectl get events -n network --field-selector involvedObject.kind=Ingress
```{{exec}}

## Ingress Controller Events

```plain
kubectl get events -n ingress-nginx --sort-by=.metadata.creationTimestamp --tail=10
```{{exec}}

## SSL/TLS Ingress (Bonus)

Maak een TLS ingress voor demonstratie:

```plain
# Maak een self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=secure.local/O=demo"

# Maak TLS secret
kubectl create secret tls secure-tls \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n network

# Maak TLS ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  namespace: network
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - secure.local
    secretName: secure-tls
  rules:
  - host: secure.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
EOF
```{{exec}}

Test HTTPS toegang:

```plain
kubectl exec debug-pod -n network -- curl -s -k -H "Host: secure.local" https://$INGRESS_IP
```{{exec}}

## Ingress Path-based Routing

Test verschillende paths op de API ingress:

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api
```{{exec}}

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$INGRESS_IP/api/health || echo "Path mogelijk niet beschikbaar"
```{{exec}}

## Load Balancer Service (NodePort)

Test de NodePort service als load balancer:

```plain
kubectl get service frontend-nodeport -n network
```{{exec}}

Test toegang via NodePort:

```plain
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$NODE_IP:30080
```{{exec}}

## Ingress Troubleshooting Workflow

### 1. **Check Ingress Exists**
```bash
kubectl get ingress <ingress-name> -n <namespace>
```

### 2. **Validate Backend Service**
```bash
kubectl get service <backend-service> -n <namespace>
```

### 3. **Check Service Endpoints**
```bash
kubectl get endpoints <backend-service> -n <namespace>
```

### 4. **Test Internal Connectivity**
```bash
kubectl exec <pod> -- curl http://<service>
```

### 5. **Check Ingress Controller**
```bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### 6. **Test External Access**
```bash
curl -H "Host: <hostname>" http://<ingress-ip>
```

## Ingress Debugging Checklist

### ✅ **Ingress Configuration**
- Host rules zijn correct
- Path routing is juist
- Backend service bestaat
- Service ports kloppen

### ✅ **Backend Services**
- Service heeft endpoints
- Pods zijn ready
- Port mapping is correct

### ✅ **Ingress Controller**
- Controller pods zijn running
- Controller service is accessible
- Logs tonen geen errors

### ✅ **Network Connectivity**
- DNS resolution werkt
- Internal service connectivity werkt
- External ingress toegang werkt

## Fixing the Broken Ingress

Laten we de broken ingress repareren:

```plain
kubectl patch ingress broken-ingress -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/http/paths/0/backend/service/name",
    "value": "frontend-service"
  }
]'
```{{exec}}

Test de gerepareerde ingress:

```plain
kubectl exec debug-pod -n network -- curl -s -H "Host: broken.local" http://$INGRESS_IP
```{{exec}}

## Cleanup

Verwijder tijdelijke bestanden:

```plain
rm -f /tmp/tls.key /tmp/tls.crt
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Ingress Troubleshooting

Je gaat nu ingress problemen diagnosticeren en repareren.

1. **Identificeer de broken ingress** en analyseer waarom het niet werkt
2. **Test ingress toegang** met de juiste Host headers
3. **Repareer het probleem** door de configuratie aan te passen

**Maak een Secret aan** met de naam `ingress-diagnosis`:

```bash
kubectl create secret generic ingress-diagnosis \
  --from-literal=broken-ingress="<ingress-naam>" \
  --from-literal=problem-cause="<oorzaak-van-probleem>" \
  --from-literal=fix-applied="<wat-je-hebt-gerepareerd>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je ingress problemen kunt diagnosticeren
- ✅ Of je de juiste Host headers gebruikt voor testing
- ✅ Of je ingress configuratie kunt repareren