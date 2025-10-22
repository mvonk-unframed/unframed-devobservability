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
2. **Zoek alle nginx-gerelateerde pods** (pods met "nginx" in de naam)
3. **Tel alle services** in het hele cluster

**Maak een Secret aan** in de `default` namespace met de naam `cluster-analysis` die deze informatie bevat:

```bash
# Voorbeeld (vervang met je eigen tellingen):
kubectl create secret generic cluster-analysis \
  --from-literal=total-pods=15 \
  --from-literal=nginx-pods=3 \
  --from-literal=total-services=8
```

### Bonus Opdracht: Label-based Search

Zoek naar alle pods met het label `app=frontend` across alle namespaces en maak een ConfigMap aan met de naam `label-search` die het aantal bevat:

```bash
kubectl create configmap label-search \
  --from-literal=frontend-pods=2
```

### Verificatie

De verificatie controleert:
- ✅ Of je cluster-brede resource viewing beheerst
- ✅ Of je een Secret hebt aangemaakt met correcte cluster tellingen
- ✅ Of je gefilterd zoeken across namespaces kunt uitvoeren

## Waarom Cross-namespace Viewing?

Cross-namespace viewing is handig voor:
1. **Cluster Monitoring**: Overzicht van de hele cluster status
2. **Troubleshooting**: Zoeken naar problemen across het hele cluster
3. **Resource Planning**: Zien waar resources worden gebruikt
4. **Security Auditing**: Controleren van configuraties cluster-breed

## Praktische Tip

Gebruik aliassen om tijd te besparen:
- `alias kgp='kubectl get pods'`
- `alias kgpa='kubectl get pods --all-namespaces'`
- `alias kgd='kubectl get deployments'`

Dit maakt je workflow veel sneller!