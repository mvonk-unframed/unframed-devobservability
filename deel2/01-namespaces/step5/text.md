# Stap 5: Cross-namespace Resource Viewing

Soms wil je een overzicht van alle resources in het hele cluster, ongeacht de namespace. Hier leer je hoe je dat doet.

## Alle Pods in Alle Namespaces

De `--all-namespaces` flag toont resources uit alle namespaces tegelijk:

```plain
kubectl get pods --all-namespaces
```{{exec}}

Je kunt ook de korte versie gebruiken:

```plain
kubectl get pods -A
```{{exec}}

## Alle Deployments Cluster-breed

Bekijk alle deployments in het hele cluster:

```plain
kubectl get deployments --all-namespaces
```{{exec}}

## Alle Services Cluster-breed

En alle services:

```plain
kubectl get services --all-namespaces
```{{exec}}

## Gefilterd Zoeken Across Namespaces

Je kunt ook zoeken naar specifieke resources across namespaces. Bijvoorbeeld, zoek naar alle nginx pods:

```plain
kubectl get pods --all-namespaces | grep nginx
```{{exec}}

Of zoek naar alle frontend gerelateerde deployments:

```plain
kubectl get deployments --all-namespaces | grep frontend
```{{exec}}

## Resource Overzicht per Type

Voor een volledig overzicht van alle resources:

```plain
kubectl get all --all-namespaces
```{{exec}}

**Let op**: Dit commando kan veel output geven!

## Specifieke Labels Across Namespaces

Je kunt ook zoeken op labels across alle namespaces:

```plain
kubectl get pods --all-namespaces -l app=frontend
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Cluster-brede Resource Analyse

Je gaat nu een cluster-brede analyse uitvoeren en de resultaten opslaan in een Secret.

1. **Tel alle pods** in het hele cluster (alle namespaces)
1. **Tel alle deployments** in het hele cluster (alle namespaces)
3. **Tel alle services** in het hele cluster (alle namespaces)

**Maak een Secret aan** in de `default` namespace met de naam `cluster-analysis` die deze informatie bevat:

```bash
# Voorbeeld (vervang met je eigen tellingen):
kubectl create secret generic cluster-analysis \
  --from-literal=total-pods=15 \
  --from-literal=total-deployments=3 \
  --from-literal=total-services=8
```

**TIP** Gebruik `wc -l` om regels te tellen, `--no-headers` bij `kubectl` om de headers weg te halen