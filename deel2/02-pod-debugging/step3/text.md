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

## 🎯 Praktische Opdracht

### Opdracht: Events Analyse en Probleem Identificatie

Je gaat nu events analyseren om pod problemen te diagnosticeren.

1. **Zoek een pod met "ImagePullBackOff" status** en analyseer de events
2. **Zoek een pod met "Pending" status** en identificeer waarom het niet kan starten
3. **Maak een Secret aan** met de naam `problem-diagnosis` die de problemen documenteert:

```bash
kubectl create secret generic problem-diagnosis \
  --from-literal=imagepull-pod="<pod-naam>" \
  --from-literal=imagepull-reason="<reden-uit-events>" \
  --from-literal=pending-pod="<pod-naam>" \
  --from-literal=pending-reason="<reden-uit-events>"
```

### Bonus Opdracht: Event Timeline

Maak een ConfigMap aan met de naam `event-timeline` die de laatste 5 warning events bevat:

```bash
# Gebruik dit commando om warnings te vinden:
kubectl get events -n debugging --field-selector type=Warning --sort-by=.metadata.creationTimestamp

# Maak ConfigMap aan met aantal warnings:
kubectl create configmap event-timeline \
  --from-literal=warning-count="<aantal-warnings>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je events kunt analyseren en problemen kunt identificeren
- ✅ Of je de juiste pod namen en redenen hebt gevonden
- ✅ Of je begrijpt hoe events helpen bij debugging

**Tip**: Gebruik [`kubectl describe pod <naam> -n debugging`](kubectl describe pod <naam> -n debugging) om gedetailleerde events te zien!