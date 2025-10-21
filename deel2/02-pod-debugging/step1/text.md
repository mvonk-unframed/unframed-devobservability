# Stap 1: Pod Status Overzicht

## Pod Lifecycle Begrijpen

Pods hebben verschillende states tijdens hun lifecycle. Het begrijpen van deze states is cruciaal voor effectieve debugging.

## Bekijk Alle Pods in de Debugging Namespace

Laten we beginnen met het bekijken van alle pods in de debugging namespace:

```plain
kubectl get pods -n debugging
```{{exec}}

## Pod Status Interpretatie

Je zult verschillende statussen zien. Hier is wat ze betekenen:

### Normale States:
- **Running**: Pod draait normaal en alle containers zijn gestart
- **Succeeded**: Pod heeft zijn taak voltooid (meestal voor Jobs)
- **Pending**: Pod wacht op scheduling of resources

### Probleem States:
- **CrashLoopBackOff**: Pod crasht herhaaldelijk en Kubernetes probeert het opnieuw
- **ImagePullBackOff**: Kan de container image niet downloaden
- **Error**: Pod is gestopt vanwege een fout
- **OOMKilled**: Pod is gestopt vanwege memory limiet overschrijding

## Gedetailleerde Status Bekijken

Voor meer details over de pod status:

```plain
kubectl get pods -n debugging -o wide
```{{exec}}

Dit toont extra informatie zoals:
- **NODE**: Op welke node de pod draait
- **NOMINATED NODE**: Voor pending pods
- **READINESS GATES**: Custom readiness checks

## Pod Status met Timestamps

Om te zien hoe lang pods in hun huidige state zijn:

```plain
kubectl get pods -n debugging --sort-by=.metadata.creationTimestamp
```{{exec}}

## Wat Zie Je?

Analyseer de output en identificeer:
1. Welke pods draaien normaal (Running)?
2. Welke pods hebben problemen?
3. Welke error states zie je?
4. Hoe lang zijn de pods al in hun huidige state?

## Ready vs Status

Let op het verschil tussen **READY** en **STATUS**:
- **READY**: Hoeveel containers ready zijn (bijv. 1/1)
- **STATUS**: De huidige lifecycle state van de pod

Een pod kan **Running** zijn maar **0/1 Ready** als de readiness probe faalt!