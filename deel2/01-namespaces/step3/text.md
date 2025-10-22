# Stap 3: Resources per Namespace

Nu je weet hoe je namespaces kunt bekijken, gaan we verkennen welke resources er in elke namespace draaien.

## Pods in een Specifieke Namespace

Standaard toont `kubectl get pods` alleen pods in de `default` namespace. Om pods in een andere namespace te zien, gebruik je de `-n` (namespace) flag:

```plain
kubectl get pods -n webapp
```{{exec}}

Bekijk ook de pods in de database namespace:

```plain
kubectl get pods -n database
```{{exec}}

En in de monitoring namespace:

```plain
kubectl get pods -n monitoring
```{{exec}}

## Deployments per Namespace

Naast pods kun je ook andere resources per namespace bekijken:

```plain
kubectl get deployments -n webapp
```{{exec}}

```plain
kubectl get deployments -n database
```{{exec}}

## Services per Namespace

Bekijk welke services er in elke namespace draaien:

```plain
kubectl get services -n webapp
```{{exec}}

```plain
kubectl get services -n database
```{{exec}}

## Alle Resources in een Namespace

Je kunt ook alle resources in een namespace tegelijk bekijken:

```plain
kubectl get all -n webapp
```{{exec}}

Probeer dit ook voor de monitoring namespace:

```plain
kubectl get all -n monitoring
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Resource Inventarisatie

Je gaat nu een inventarisatie maken van resources per namespace door een Secret aan te maken met de resource tellingen.

1. **Tel de pods** in de webapp namespace
2. **Tel de services** in de database namespace
3. **Tel de deployments** in de monitoring namespace

**Maak een Secret aan** in de `default` namespace met de naam `resource-count` die deze informatie bevat:

```bash
# Voorbeeld (vervang de getallen met je eigen tellingen):
kubectl create secret generic resource-count \
  --from-literal=webapp-pods=3 \
  --from-literal=database-services=2 \
  --from-literal=monitoring-deployments=1
```

### Bonus Opdracht: Resource Overzicht

Maak een ConfigMap aan met de naam `namespace-resources` die een overzicht bevat van welke resource types je hebt gevonden in elke namespace.

**Voorbeeld:**
```bash
kubectl create configmap namespace-resources \
  --from-literal=webapp="pods,services,deployments" \
  --from-literal=database="pods,services" \
  --from-literal=monitoring="pods,deployments"
```

### Verificatie

De verificatie controleert:
- ✅ Of je resources in verschillende namespaces hebt bekeken
- ✅ Of je een Secret hebt aangemaakt met correcte resource tellingen
- ✅ Of je begrijpt hoe namespace isolatie werkt

**Tip:** Gebruik [`kubectl get all -n <namespace>`](kubectl get all -n <namespace>) om alle standaard resources in één keer te zien!