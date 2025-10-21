# Deel 2 - Kubernetes Debugging Ontwerp

## Overzicht
Cursisten zonder Kubernetes kennis worden binnen 60 minuten getoetst op essentiële debugging vaardigheden.

## Scenario Structuur

### 1. Namespaces Verkenning
**Map:** `deel2/01-namespaces/`
**Tijd:** ~8 minuten
**Doel:** Begrip van namespace concept en navigatie

#### Pre-setup:
- Kubernetes cluster met meerdere namespaces
- Verschillende applicaties per namespace (web, database, monitoring)
- Enkele pods in verschillende states

#### Stappen:
1. **Namespace concept** - Uitleg wat namespaces zijn en waarom ze gebruikt worden
2. **Alle namespaces tonen** - `kubectl get namespaces`
3. **Namespace specifieke resources** - `kubectl get pods -n <namespace>`
4. **Default namespace instellen** - `kubectl config set-context --current --namespace=<ns>`
5. **Cross-namespace resource viewing** - `kubectl get pods --all-namespaces`

#### Verificatie:
- Controleer of gebruiker juiste namespaces kan identificeren
- Test begrip van namespace isolation
- Verificeer dat ze resources in specifieke namespaces kunnen vinden

### 2. Pod Status en Resource Debugging
**Map:** `deel2/02-pod-debugging/`
**Tijd:** ~15 minuten
**Doel:** Pod lifecycle, resource verbruik en problemen diagnosticeren

#### Pre-setup:
- Pods in verschillende states: Running, Pending, CrashLoopBackOff, ImagePullBackOff
- Broken deployment met resource limits (CPU/Memory)
- Pod met failing health checks
- High resource consuming pods

#### Stappen:
1. **Pod status overzicht** - `kubectl get pods` en status interpretatie
2. **Resource verbruik controleren** - `kubectl top pods` en `kubectl top nodes`
3. **Gedetailleerde pod info** - `kubectl describe pod <name>` (focus op Events en Resources)
4. **Pod logs bekijken** - `kubectl logs <pod>` en `kubectl logs -f <pod>`
5. **Previous container logs** - `kubectl logs <pod> --previous`
6. **Pod debugging scenario's**:
   - ImagePullBackOff: Verkeerde image naam
   - CrashLoopBackOff: Applicatie crash door missing config
   - Pending: Resource constraints (CPU/Memory limits)
   - OOMKilled: Memory limit overschreden

#### Praktische Oefening:
```bash
# Scenario: Web applicatie crasht en resource problemen
kubectl get pods -n webapp
kubectl top pods -n webapp  # Check resource usage
kubectl describe pod webapp-broken-xyz
kubectl logs webapp-broken-xyz
# Diagnose: OOMKilled door te weinig memory limit
```

#### Verificatie:
- Test of gebruiker oorzaak van pod failures kan identificeren
- Controleer begrip van resource limits en requests
- Verificeer dat ze resource verbruik kunnen monitoren
- Test begrip van verschillende pod states en resource gerelateerde errors

### 3. Secrets en Credentials
**Map:** `deel2/03-secrets-debugging/`
**Tijd:** ~12 minuten
**Doel:** Secret management en credential troubleshooting

#### Pre-setup:
- Applicatie pods die secrets gebruiken
- Broken secret references
- Database connection issues door verkeerde credentials

#### Stappen:
1. **Secrets overzicht** - `kubectl get secrets`
2. **Secret details** - `kubectl describe secret <name>`
3. **Secret inhoud bekijken** - `kubectl get secret <name> -o yaml`
4. **Base64 decoding** - Secrets decoderen om inhoud te zien
5. **Pod-Secret verbindingen** - Welke pods gebruiken welke secrets
6. **Troubleshooting scenario**: Database connectie faalt

#### Praktische Oefening:
```bash
# Vind welke credentials de webapp gebruikt
kubectl get pods webapp-123 -o yaml | grep -A5 -B5 secret
kubectl get secret webapp-db-credentials -o yaml
echo "cGFzc3dvcmQ=" | base64 -d
```

#### Verificatie:
- Test of gebruiker secret-pod relaties kan identificeren
- Controleer begrip van base64 encoding/decoding
- Verificeer dat ze credential issues kunnen diagnosticeren

### 4. SOPS Secret Management
**Map:** `deel2/04-sops-secrets/`
**Tijd:** ~10 minuten
**Doel:** Encrypted secrets beheren met SOPS

#### Pre-setup:
- SOPS tool geïnstalleerd
- GPG keys geconfigureerd
- Encrypted secret files
- Age key voor decryptie

#### Stappen:
1. **SOPS concept** - Waarom encrypted secrets belangrijk zijn
2. **Secret decrypten** - `sops -d secret.yaml`
3. **Secret bewerken** - `sops secret.yaml` (opent editor)
4. **Nieuwe waarde toevoegen** - Database password wijzigen
5. **Secret encrypten** - Automatisch bij save in SOPS editor
6. **Kubernetes toepassen** - `kubectl apply -f secret.yaml`

#### Praktische Oefening:
```bash
# Scenario: Database password moet gewijzigd worden
sops -d database-secret.yaml  # Bekijk huidige waarden
sops database-secret.yaml     # Bewerk (wijzig password)
kubectl apply -f database-secret.yaml
kubectl rollout restart deployment webapp
```

#### Verificatie:
- Test of gebruiker SOPS kan gebruiken voor decrypt/encrypt
- Controleer dat ze secrets veilig kunnen bewerken
- Verificeer begrip van secret rotation process

### 5. Services en Ingress Debugging
**Map:** `deel2/05-network-debugging/`
**Tijd:** ~15 minuten
**Doel:** Netwerk connectivity en service discovery troubleshooting

#### Pre-setup:
- Web applicatie met service en ingress
- Broken service selector
- Pod met failing readiness probe
- Ingress met verkeerde backend configuratie

#### Stappen:
1. **Service overzicht** - `kubectl get services`
2. **Service endpoints** - `kubectl get endpoints <service>`
3. **Service-Pod verbinding** - Label selectors controleren
4. **Ingress configuratie** - `kubectl get ingress` en `kubectl describe ingress`
5. **Readiness/Liveness probes** - Pod health checks begrijpen
6. **Troubleshooting scenario**: Website is niet bereikbaar

#### Praktische Oefening - Website Down Scenario:
```bash
# Stap 1: Controleer ingress
kubectl get ingress webapp-ingress
curl -H "Host: webapp.local" http://localhost

# Stap 2: Controleer service
kubectl get svc webapp-service
kubectl get endpoints webapp-service

# Stap 3: Controleer pods
kubectl get pods -l app=webapp
kubectl describe pod webapp-xyz

# Diagnose: Readiness probe faalt omdat /health endpoint nog niet ready is
```

#### Verificatie:
- Test of gebruiker network flow kan traceren (Ingress → Service → Pod)
- Controleer begrip van service selectors en endpoints
- Verificeer dat ze readiness probe issues kunnen identificeren

## Technische Implementatie

### Backend Configuration:
```json
{
  "backend": {
    "imageid": "kubernetes-kubeadm-1node"
  }
}
```

### Pre-setup Scripts:
Elk scenario krijgt een `background.sh` die:
- Kubernetes resources deployed (pods, services, secrets, ingress)
- Realistische problemen introduceert
- SOPS en GPG keys configureert
- Sample applicaties met verschillende failure modes

### Voorbeeld Background Script:
```bash
#!/bin/bash
# Setup voor pod debugging scenario

# Deploy werkende webapp
kubectl create namespace webapp
kubectl create deployment webapp --image=nginx:1.20 -n webapp

# Deploy broken webapp (verkeerde image)
kubectl create deployment webapp-broken --image=nginx:nonexistent -n webapp

# Deploy webapp met resource limits (pending state)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-pending
  namespace: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp-pending
  template:
    metadata:
      labels:
        app: webapp-pending
    spec:
      containers:
      - name: webapp
        image: nginx:1.20
        resources:
          requests:
            memory: "10Gi"  # Te veel memory - zal pending blijven
EOF

# Wacht tot pods in verschillende states zijn
sleep 30
```

### SOPS Setup Script:
```bash
#!/bin/bash
# SOPS configuratie

# Installeer SOPS
curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux
chmod +x sops-v3.7.3.linux
mv sops-v3.7.3.linux /usr/local/bin/sops

# Genereer age key
age-keygen -o /root/.age/key.txt
export SOPS_AGE_KEY_FILE=/root/.age/key.txt

# Maak encrypted secret
cat <<EOF > database-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
  namespace: webapp
type: Opaque
data:
  username: $(echo -n "dbuser" | base64)
  password: $(echo -n "oldpassword123" | base64)
EOF

# Encrypt met SOPS
sops -e -i database-secret.yaml
```

## Tijdsindeling per Scenario:
1. Namespaces: 8 min
2. Pod & Resource debugging: 15 min
3. Secrets: 12 min
4. SOPS: 10 min
5. Services & Ingress: 15 min

**Totaal: 60 minuten**

## Leeruitkomsten:
Na afloop kunnen cursisten:
- Kubernetes namespaces begrijpen en navigeren
- Pod problemen diagnosticeren aan de hand van status, logs en resource verbruik
- Resource limits en requests begrijpen en troubleshooten
- `kubectl top` gebruiken voor resource monitoring
- Secret management en credential troubleshooting
- SOPS gebruiken voor veilige secret management
- Netwerk connectivity issues debuggen (Service → Pod flow)
- Readiness/liveness probe problemen identificeren

## Realistische Scenario's:
Alle oefeningen zijn gebaseerd op echte productie problemen:
- ImagePullBackOff door typos in deployment
- CrashLoopBackOff door missing environment variables
- Service discovery issues door verkeerde labels
- Ingress problemen door backend configuratie
- Secret rotation workflows