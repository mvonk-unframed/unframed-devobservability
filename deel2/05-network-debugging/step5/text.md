# Stap 5: Praktische Network Debugging Scenario

## 🚨 Incident Response: "Website Down!"

Je krijgt een urgent ticket: **"De website is niet bereikbaar en klanten kunnen niet inloggen!"**

Dit is een realistische network debugging scenario waarbij je systematisch de **Extern → Ingress → Service → Pod** flow gaat troubleshooten.

## Incident Assessment

Start met een snelle assessment van de situatie:

```plain
echo "=== INCIDENT ASSESSMENT ==="
echo "Timestamp: $(date)"
echo "Issue: Website not accessible"

echo "1. Overall cluster status:"
kubectl get nodes

echo "2. Network namespace status:"
kubectl get all -n network

echo "3. Ingress status:"
kubectl get ingress -n network
```{{exec}}

## Systematic Debugging: Extern → Ingress

**Stap 1: Controleer externe toegang naar ingress**

```plain
echo "=== STEP 1: EXTERNAL → INGRESS ==="

echo "Ingress controller status:"
kubectl get pods -n ingress-nginx

echo "Ingress controller service:"
kubectl get service ingress-nginx-controller -n ingress-nginx

INGRESS_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}')
echo "Ingress IP: $INGRESS_IP"

echo "Testing external access to ingress:"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -2 || echo "❌ External access failed"
```{{exec}}

## Systematic Debugging: Ingress → Service

**Stap 2: Controleer ingress naar service routing**

```plain
echo "=== STEP 2: INGRESS → SERVICE ==="

echo "Frontend ingress backend configuration:"
kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend}' | jq .

echo "Backend service exists?"
kubectl get service frontend-service -n network || echo "❌ Service missing"

echo "Testing ingress to service routing:"
kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | head -2
```{{exec}}

## Systematic Debugging: Service → Pod

**Stap 3: Controleer service naar pod connectivity**

```plain
echo "=== STEP 3: SERVICE → POD ==="

echo "Service endpoints:"
kubectl get endpoints frontend-service -n network

echo "Pod status:"
kubectl get pods -n network -l app=frontend

echo "Testing direct service access:"
kubectl exec debug-pod -n network -- curl -s http://frontend-service | head -2

echo "Testing direct pod access:"
POD_IP=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}')
kubectl exec debug-pod -n network -- curl -s http://$POD_IP | head -2
```{{exec}}

## Root Cause Analysis

**Identificeer en repareer problemen:**

```plain
echo "=== ROOT CAUSE ANALYSIS ==="

echo "Checking for services without endpoints:"
kubectl get endpoints -n network | grep "<none>" && echo "❌ Found services without endpoints" || echo "✅ All services have endpoints"

echo "Checking for failing readiness probes:"
kubectl get pods -n network | grep "0/" && echo "❌ Found pods not ready" || echo "✅ All pods ready"

echo "Checking ingress backend issues:"
kubectl describe ingress broken-ingress -n network | grep -i error || echo "✅ No obvious ingress errors"
```{{exec}}

## Fix Implementation

**Repareer geïdentificeerde problemen:**

```plain
echo "=== IMPLEMENTING FIXES ==="

echo "Fix 1: Repair broken ingress backend"
kubectl patch ingress broken-ingress -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/rules/0/http/paths/0/backend/service/name",
    "value": "frontend-service"
  }
]'

echo "Fix 2: Repair failing readiness probe"
kubectl patch deployment failing-readiness -n network --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/path",
    "value": "/"
  }
]'

echo "Waiting for fixes to apply..."
kubectl rollout status deployment/failing-readiness -n network --timeout=60s
```{{exec}}

## Post-Fix Validation

**Valideer dat alle fixes werken:**

```plain
echo "=== POST-FIX VALIDATION ==="

echo "Testing complete flow after fixes:"
for host in frontend.local api.local broken.local; do
  echo "Testing $host:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: $host" http://$INGRESS_IP | head -1
done

echo "Checking all services have endpoints:"
kubectl get endpoints -n network

echo "Checking all pods are ready:"
kubectl get pods -n network
```{{exec}}

## Load Testing & Performance

**Test dat de applicatie onder load werkt:**

```plain
echo "=== LOAD TESTING ==="

echo "Testing load balancing:"
for i in {1..5}; do
  echo "Request $i:"
  kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$INGRESS_IP | grep -i "welcome\|nginx" | head -1
done

echo "Testing response times:"
kubectl exec debug-pod -n network -- time curl -s -H "Host: frontend.local" http://$INGRESS_IP >/dev/null
```{{exec}}

## Incident Resolution Report

**Genereer een incident report:**

```plain
echo "=== INCIDENT RESOLUTION REPORT ==="

echo "Incident: Website not accessible"
echo "Root Causes Found:"
echo "1. Broken ingress pointing to non-existent service"
echo "2. Failing readiness probes preventing pod endpoints"

echo "Fixes Applied:"
echo "1. Updated broken-ingress backend to point to frontend-service"
echo "2. Fixed readiness probe path from /nonexistent to /"

echo "Current Status:"
TOTAL_PODS=$(kubectl get pods -n network --no-headers | wc -l)
READY_PODS=$(kubectl get pods -n network --no-headers | grep "1/1\|2/2" | wc -l)
INGRESS_COUNT=$(kubectl get ingress -n network --no-headers | wc -l)

echo "- Total pods: $TOTAL_PODS"
echo "- Ready pods: $READY_PODS"
echo "- Ingress resources: $INGRESS_COUNT"

if [ "$READY_PODS" -eq "$TOTAL_PODS" ]; then
  echo "✅ INCIDENT RESOLVED - All systems operational"
else
  echo "⚠️ PARTIAL RESOLUTION - Some issues remain"
fi
```{{exec}}

## Network Debugging Mastery

### 🎯 **Systematic Approach**
1. **Assess** overall situation quickly
2. **Follow the flow** systematically: Extern → Ingress → Service → Pod
3. **Identify** root causes, not just symptoms
4. **Fix** configuration issues
5. **Validate** end-to-end functionality
6. **Document** findings and fixes

### 🔧 **Key Debugging Commands**
```bash
# Quick assessment
kubectl get all -n <namespace>
kubectl get ingress -n <namespace>

# Flow testing
curl -H "Host: <hostname>" http://<ingress-ip>
kubectl exec <pod> -- curl http://<service>

# Root cause analysis
kubectl get endpoints <service>
kubectl describe pod <pod>
kubectl logs <pod>
```

## 🎯 Praktische Opdracht

### Opdracht: Complete Incident Response

Je hebt nu een complete incident response doorlopen. Documenteer je bevindingen:

**Maak een Secret aan** met de naam `incident-report`:

```bash
kubectl create secret generic incident-report \
  --from-literal=root-cause-1="<eerste-probleem-gevonden>" \
  --from-literal=root-cause-2="<tweede-probleem-gevonden>" \
  --from-literal=resolution-status="resolved/partial/unresolved"
```

### Verificatie

De verificatie controleert:
- ✅ Of je systematisch de network flow kunt debuggen
- ✅ Of je root causes kunt identificeren en repareren
- ✅ Of je end-to-end connectivity kunt valideren

## 🏆 Gefeliciteerd!

Je hebt succesvol een complete network debugging scenario doorlopen! Je kunt nu:

- **Systematisch** network problemen debuggen
- **De flow volgen** van extern naar pod
- **Root causes identificeren** en repareren
- **End-to-end connectivity** valideren

Deze vaardigheden zijn essentieel voor elke DevOps engineer die met Kubernetes werkt!