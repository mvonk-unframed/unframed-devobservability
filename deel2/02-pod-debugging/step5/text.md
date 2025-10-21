# Stap 5: Pod Debugging Scenario's

## Praktische Debugging Oefening

Nu ga je de geleerde technieken toepassen op echte debugging scenario's. Je gaat verschillende pod problemen diagnosticeren en de oorzaken identificeren.

## Scenario 1: ImagePullBackOff Debugging

Vind de pod met image problemen:

```plain
kubectl get pods -n debugging | grep ImagePullBackOff
```{{exec}}

Analyseer het probleem:

```plain
kubectl get pods -n debugging -o name | grep broken-image | head -1 | xargs kubectl describe -n debugging
```{{exec}}

**Vraag**: Wat is de oorzaak van dit probleem? Kijk naar de Events sectie!

## Scenario 2: Resource Constraint Debugging

Vind de pod die Pending is vanwege resources:

```plain
kubectl get pods -n debugging | grep Pending
```{{exec}}

Analyseer waarom deze pod niet kan starten:

```plain
kubectl get pods -n debugging -o name | grep resource-hungry | head -1 | xargs kubectl describe -n debugging
```{{exec}}

**Vraag**: Hoeveel memory vraagt deze pod en waarom kan het niet gescheduled worden?

## Scenario 3: OOMKilled Debugging

Bekijk de memory-hog pod:

```plain
kubectl get pods -n debugging | grep memory-hog
```{{exec}}

Beschrijf de pod om de memory limits te zien:

```plain
kubectl get pods -n debugging -o name | grep memory-hog | head -1 | xargs kubectl describe -n debugging
```{{exec}}

Bekijk de logs om te zien wat er gebeurde:

```plain
kubectl logs -n debugging -l app=memory-hog --previous
```{{exec}}

**Vraag**: Wat is de memory limit en waarom wordt de pod gekilled?

## Scenario 4: CrashLoopBackOff Debugging

Analyseer de crashende applicatie:

```plain
kubectl get pods -n debugging | grep CrashLoopBackOff
```{{exec}}

Bekijk de huidige logs:

```plain
kubectl logs -n debugging -l app=crash-app
```{{exec}}

Bekijk de previous logs:

```plain
kubectl logs -n debugging -l app=crash-app --previous
```{{exec}}

**Vraag**: Wat veroorzaakt de crash en hoe vaak probeert Kubernetes het opnieuw?

## Scenario 5: Readiness Probe Failure

Vind pods die Running zijn maar niet Ready:

```plain
kubectl get pods -n debugging | grep "0/"
```{{exec}}

Analyseer de readiness probe failure:

```plain
kubectl get pods -n debugging -o name | grep failing-readiness | head -1 | xargs kubectl describe -n debugging
```{{exec}}

**Vraag**: Waarom faalt de readiness probe?

## Scenario 6: High Resource Usage

Bekijk welke pods veel resources gebruiken:

```plain
kubectl top pods -n debugging --sort-by=cpu
```{{exec}}

```plain
kubectl top pods -n debugging --sort-by=memory
```{{exec}}

## Debugging Workflow Samenvatting

Voor elk pod probleem, volg deze stappen:

### 1. **Identificeer het Probleem**
```bash
kubectl get pods -n debugging
```

### 2. **Analyseer Pod Details**
```bash
kubectl describe pod <pod-name> -n debugging
```

### 3. **Bekijk Events**
Focus op de Events sectie in describe output

### 4. **Controleer Logs**
```bash
kubectl logs <pod-name> -n debugging
kubectl logs <pod-name> -n debugging --previous
```

### 5. **Check Resource Usage**
```bash
kubectl top pods -n debugging
```

## Veelvoorkomende Problemen en Oplossingen

| Probleem | Oorzaak | Oplossing |
|----------|---------|-----------|
| ImagePullBackOff | Verkeerde image naam/tag | Corrigeer image in deployment |
| Pending | Onvoldoende resources | Verhoog cluster capacity of verlaag requests |
| CrashLoopBackOff | Applicatie crash | Fix applicatie code of configuratie |
| OOMKilled | Memory limit overschreden | Verhoog memory limit |
| 0/1 Ready | Readiness probe faalt | Fix health check endpoint |

Probeer nu alle scenario's te analyseren en de oorzaken te identificeren!