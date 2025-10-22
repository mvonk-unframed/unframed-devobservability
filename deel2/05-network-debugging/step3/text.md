# Stap 3: Pod-to-Service Connectivity

## Pod-to-Service Communication Testen

Nu gaan we testen hoe pods met services communiceren en veelvoorkomende connectivity problemen diagnosticeren.

## Basic Connectivity Testing

Test connectivity van debug pod naar frontend service:

```plain
kubectl exec debug-pod -n network -- curl -s http://frontend-service.network.svc.cluster.local
```{{exec}}

Test met korte service naam:

```plain
kubectl exec debug-pod -n network -- curl -s http://frontend-service
```{{exec}}

## Backend API Connectivity

Test connectivity naar backend service op specifieke port:

```plain
kubectl exec debug-pod -n network -- curl -s http://backend-service.network.svc.cluster.local:8080
```{{exec}}

## Database Connectivity Testing

Test database connectivity (PostgreSQL):

```plain
kubectl exec debug-pod -n network -- nc -zv database-service.network.svc.cluster.local 5432
```{{exec}}

## Service Port vs Target Port

Begrijp het verschil tussen service port en target port:

```plain
echo "=== BACKEND SERVICE PORTS ==="
kubectl get service backend-service -n network -o jsonpath='{.spec.ports}' | jq .
```{{exec}}

Test beide poorten:

```plain
# Service port (8080)
kubectl exec debug-pod -n network -- curl -s http://backend-service:8080

# Direct pod port zou 80 zijn
kubectl exec debug-pod -n network -- curl -s http://$(kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].status.podIP}'):80
```{{exec}}

## Client Pod Testing

Gebruik de client pod voor meer realistische testing:

```plain
kubectl exec client-pod -n network -- curl -s http://frontend-service.network.svc.cluster.local
```{{exec}}

## Cross-Namespace Connectivity

Test connectivity naar services in andere namespaces:

```plain
kubectl exec debug-pod -n network -- curl -s http://kubernetes.default.svc.cluster.local
```{{exec}}

## Failing Service Connectivity

Test connectivity naar de failing-readiness service:

```plain
kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://failing-readiness-service.network.svc.cluster.local
```{{exec}}

Waarom faalt dit? Bekijk de service endpoints:

```plain
kubectl get endpoints failing-readiness-service -n network
```{{exec}}

## Network Troubleshooting Tools

### 1. **DNS Resolution Testing**

```plain
kubectl exec debug-pod -n network -- nslookup frontend-service.network.svc.cluster.local
```{{exec}}

### 2. **Port Connectivity Testing**

```plain
kubectl exec debug-pod -n network -- nc -zv frontend-service 80
```{{exec}}

### 3. **Trace Route (als beschikbaar)**

```plain
kubectl exec debug-pod -n network -- traceroute frontend-service.network.svc.cluster.local
```{{exec}}

### 4. **Network Interface Info**

```plain
kubectl exec debug-pod -n network -- ip addr show
```{{exec}}

## Service Load Balancing Testing

Test load balancing door meerdere requests te maken:

```plain
for i in {1..5}; do
  echo "Request $i:"
  kubectl exec debug-pod -n network -- curl -s http://frontend-service | grep -i server || echo "No server info"
done
```{{exec}}

## Pod-to-Pod Direct Communication

Test directe pod-to-pod communicatie:

```plain
# Haal frontend pod IP op
FRONTEND_POD_IP=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}')
echo "Frontend pod IP: $FRONTEND_POD_IP"

# Test directe connectie
kubectl exec debug-pod -n network -- curl -s http://$FRONTEND_POD_IP:80
```{{exec}}

## Service vs Pod IP Testing

Vergelijk service IP met pod IPs:

```plain
echo "=== SERVICE IP ==="
kubectl get service frontend-service -n network -o jsonpath='{.spec.clusterIP}'

echo -e "\n=== POD IPs ==="
kubectl get pods -n network -l app=frontend -o jsonpath='{.items[*].status.podIP}'
```{{exec}}

## Connectivity Troubleshooting Scenario

Simuleer een connectivity probleem door een pod te labelen:

```plain
# Verwijder label van een frontend pod
FRONTEND_POD=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl label pod $FRONTEND_POD -n network app-

# Test connectivity
kubectl exec debug-pod -n network -- curl -s http://frontend-service
```{{exec}}

Bekijk wat er gebeurd is met endpoints:

```plain
kubectl get endpoints frontend-service -n network
```{{exec}}

Herstel het label:

```plain
kubectl label pod $FRONTEND_POD -n network app=frontend
```{{exec}}

## Network Policy Impact (als aanwezig)

Controleer of er network policies zijn die connectivity beïnvloeden:

```plain
kubectl get networkpolicies -n network
```{{exec}}

## Service Mesh Connectivity (als aanwezig)

Als er een service mesh is, controleer sidecar status:

```plain
kubectl get pods -n network -o jsonpath='{.items[*].spec.containers[*].name}' | grep -o istio-proxy || echo "Geen Istio sidecars gevonden"
```{{exec}}

## Connectivity Debugging Checklist

### 1. **DNS Resolution**
```bash
kubectl exec <pod> -- nslookup <service>
```

### 2. **Port Connectivity**
```bash
kubectl exec <pod> -- nc -zv <service> <port>
```

### 3. **Service Endpoints**
```bash
kubectl get endpoints <service>
```

### 4. **Pod Readiness**
```bash
kubectl get pods -o wide
```

### 5. **Network Policies**
```bash
kubectl get networkpolicies
```

## Performance Testing

Test response times:

```plain
kubectl exec debug-pod -n network -- time curl -s http://frontend-service >/dev/null
```{{exec}}

## Multiple Service Testing

Test connectivity naar alle services:

```plain
SERVICES=$(kubectl get services -n network -o jsonpath='{.items[*].metadata.name}')
for service in $SERVICES; do
  echo "Testing $service..."
  kubectl exec debug-pod -n network -- curl -s --connect-timeout 3 http://$service || echo "Failed to connect to $service"
done
```{{exec}}

## Multiple Choice Vragen

**Vraag 1:** Welk commando test of een service bereikbaar is via DNS?

A) `kubectl exec <pod> -- ping <service>`
B) `kubectl exec <pod> -- nslookup <service>`
C) `kubectl exec <pod> -- dig <service>`
D) Zowel B als C zijn correct

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: D**

Beide commando's testen DNS resolution:
- `nslookup <service>` - basis DNS lookup
- `dig <service>` - meer gedetailleerde DNS informatie

Je kunt ook de volledige FQDN gebruiken:
`nslookup frontend-service.network.svc.cluster.local`
</details>

---

**Vraag 2:** Wat is het verschil tussen service port en target port?

A) Er is geen verschil
B) Service port is extern, target port is intern
C) Service port is waar clients verbinden, target port is de pod port
D) Target port is altijd 80

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

- **Service port**: De port waar clients mee verbinden (bijv. 8080)
- **Target port**: De daadwerkelijke port op de pod (bijv. 80)

Voorbeeld:
```yaml
ports:
- port: 8080        # Service port (client verbindt hier)
  targetPort: 80    # Pod port (waar de app luistert)
```

Dit maakt port mapping mogelijk tussen service en pods.
</details>

---

**Vraag 3:** Welk tool test port connectivity zonder HTTP?

A) `curl`
B) `wget`
C) `nc` (netcat)
D) `ping`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

`nc` (netcat) test pure TCP/UDP connectivity:
- `nc -zv <service> <port>` - test of port open is
- Werkt voor alle protocols (HTTP, database, etc.)
- Geeft alleen connectiviteit info, geen HTTP response

`curl` en `wget` zijn HTTP-specifiek, `ping` test alleen ICMP (vaak geblokkeerd).
</details>

---

## Wat Heb Je Geleerd?

Je hebt nu:
- ✅ Pod-to-service connectivity getest
- ✅ DNS resolution geverifieerd
- ✅ Port connectivity gecontroleerd
- ✅ Load balancing geobserveerd
- ✅ Connectivity problemen gesimuleerd en opgelost
- ✅ Verschillende troubleshooting tools gebruikt

Pod-to-service connectivity is de basis van microservices communicatie in Kubernetes!