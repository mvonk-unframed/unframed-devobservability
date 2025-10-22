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

## 🎯 Praktische Opdracht

### Opdracht: Pod Status Analyse

Je gaat nu een analyse maken van pod statussen en deze informatie opslaan voor verificatie.

1. **Tel pods per status** in de debugging namespace:
   - Hoeveel pods hebben status "Running"?
   - Hoeveel pods hebben status "CrashLoopBackOff"?
   - Hoeveel pods hebben status "ImagePullBackOff"?

2. **Maak een ConfigMap aan** in de `default` namespace met de naam `pod-status-analysis`:

```bash
# Voorbeeld (vervang met je eigen tellingen):
kubectl create configmap pod-status-analysis \
  --from-literal=running-pods=3 \
  --from-literal=crashloop-pods=2 \
  --from-literal=imagepull-pods=1
```

### Verificatie

De verificatie controleert:
- ✅ Of je pod statussen correct hebt geteld
- ✅ Of je het verschil tussen READY en STATUS begrijpt
- ✅ Of je problematische pods kunt identificeren

## Ready vs Status

Let op het verschil tussen **READY** en **STATUS**:
- **READY**: Hoeveel containers ready zijn (bijv. 1/1)
- **STATUS**: De huidige lifecycle state van de pod

Een pod kan **Running** zijn maar **0/1 Ready** als de readiness probe faalt!