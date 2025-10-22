# Stap 3: Gedetailleerde Pod Informatie

## Waarom kubectl describe Cruciaal Is

`kubectl describe` is je beste vriend bij pod debugging. Het toont gedetailleerde informatie over de pod configuratie, status, en belangrijke events.

## Beschrijf een Werkende Pod

Laten we beginnen met een healthy pod:

```plain
kubectl describe pod -n debugging -l app=healthy-app | head -50
```{{exec}}

## Beschrijf een Pod met Problemen

Nu bekijken we een pod met problemen. Eerst vinden we een problematische pod:

```plain
kubectl get pods -n debugging | grep -E "(CrashLoopBackOff|ImagePullBackOff|Pending)"
```{{exec}}

Beschrijf een van de problematische pods (vervang POD_NAME met een echte naam):

```plain
kubectl get pods -n debugging -o name | grep broken-image | head -1 | xargs kubectl describe -n debugging
```{{exec}}

## Events Sectie Analyseren

De Events sectie is het belangrijkste deel voor debugging. Bekijk specifiek de events:

```plain
kubectl get events -n debugging --sort-by=.metadata.creationTimestamp
```{{exec}}

## Pod met Resource Problemen

Bekijk de resource-hungry pod:

```plain
kubectl get pods -n debugging -o name | grep resource-hungry | head -1 | xargs kubectl describe -n debugging
```{{exec}}

Let op de **Events** sectie - hier zie je waarom de pod Pending is!

## Pod met Memory Problemen

Beschrijf de memory-hog pod:

```plain
kubectl get pods -n debugging -o name | grep memory-hog | head -1 | xargs kubectl describe -n debugging
```{{exec}}

## Belangrijke Secties in kubectl describe

### 1. **Metadata**
- Name, Namespace, Labels, Annotations

### 2. **Spec**
- Container configuratie
- Resource requests en limits
- Volume mounts
- Security context

### 3. **Status**
- Pod phase (Pending, Running, Succeeded, Failed)
- Container statuses
- Pod IP en Node assignment

### 4. **Events** (Meest Belangrijk!)
- Scheduling events
- Image pull events
- Container start/stop events
- Error messages

## Event Types Begrijpen

Veelvoorkomende event types:
- **Scheduled**: Pod is toegewezen aan een node
- **Pulling**: Container image wordt gedownload
- **Pulled**: Image download voltooid
- **Created**: Container is aangemaakt
- **Started**: Container is gestart
- **Failed**: Actie is mislukt
- **FailedScheduling**: Pod kon niet gescheduled worden

## Multiple Choice Vragen

**Vraag 1:** Welke sectie in `kubectl describe pod` is het belangrijkst voor debugging?

A) Metadata
B) Spec
C) Status
D) Events

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: D**

De **Events** sectie is het belangrijkst voor debugging omdat het toont:
- Scheduling events
- Image pull events
- Container start/stop events
- Error messages en failure redenen
- Chronologische volgorde van wat er gebeurd is

Events vertellen je meestal direct wat er mis is gegaan.
</details>

---

**Vraag 2:** Wat betekent het event "FailedScheduling"?

A) De container is gecrashed
B) De pod kon niet toegewezen worden aan een node
C) De image kon niet gedownload worden
D) De readiness probe is gefaald

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

"FailedScheduling" betekent dat de Kubernetes scheduler de pod niet kon toewijzen aan een node. Dit kan komen door:
- Onvoldoende CPU/memory resources op nodes
- Node selectors die niet matchen
- Taints/tolerations problemen
- Anti-affinity regels

De pod blijft in "Pending" status totdat scheduling mogelijk is.
</details>

---

**Vraag 3:** Welk commando toont alleen de events van een specifieke namespace?

A) `kubectl get events`
B) `kubectl get events -n <namespace>`
C) `kubectl describe events -n <namespace>`
D) `kubectl events --namespace <namespace>`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

`kubectl get events -n <namespace>` toont alleen events uit de gespecificeerde namespace.

Handige opties:
- `kubectl get events --sort-by=.metadata.creationTimestamp` - chronologisch gesorteerd
- `kubectl get events --field-selector type=Warning` - alleen warnings
- `kubectl get events --watch` - real-time event monitoring
</details>

---

## Praktische Debugging Tips

1. **Kijk altijd eerst naar Events** - dit vertelt je meestal wat er mis is
2. **Check Resource Requests vs Node Capacity** - voor Pending pods
3. **Controleer Image Names** - voor ImagePullBackOff
4. **Bekijk Container Exit Codes** - voor CrashLoopBackOff

Analyseer de verschillende pods en identificeer de oorzaken van hun problemen!