# Stap 3: Pod Details Bekijken

## kubectl describe - Je Debugging Tool

`kubectl describe` toont alle belangrijke informatie over een pod, inclusief events die problemen verklaren.

## Bekijk een Gezonde Pod

```plain
kubectl describe pod -n debugging -l app=healthy-app | head -30
```{{exec}}

## Analyseer Problematische Pods

Vind pods met problemen:

```plain
kubectl get pods -n debugging | grep -E "(CrashLoopBackOff|ImagePullBackOff|Pending)"
```{{exec}}

Beschrijf een problematische pod:

```plain
kubectl get pods -n debugging -o name | grep broken-image | head -1 | xargs kubectl describe -n debugging
```{{exec}}

## Events - Het Belangrijkste Deel

De Events sectie onderaan vertelt je precies wat er mis is:

```plain
kubectl get events -n debugging --sort-by=.metadata.creationTimestamp
```{{exec}}

## Belangrijke Secties

- **Status**: Pod phase (Pending, Running, Failed)
- **Events**: Waarom iets mis gaat (meest belangrijk!)
- **Containers**: Resource limits en status

## Veelvoorkomende Event Types

- **FailedScheduling**: Niet genoeg resources
- **Failed to pull image**: Verkeerde image naam
- **OOMKilled**: Te veel memory gebruikt

## 🎯 Opdracht

Analyseer de events van problematische pods en maak een Secret:

```bash
kubectl create secret generic problem-diagnosis \
  --from-literal=imagepull-pod="<pod-naam>" \
  --from-literal=imagepull-reason="<reden-uit-events>" \
  --from-literal=pending-pod="<pod-naam>" \
  --from-literal=pending-reason="<reden-uit-events>"
```

**Focus op de Events sectie - daar vind je altijd de oorzaak!**