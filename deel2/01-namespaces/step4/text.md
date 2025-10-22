# Stap 4: Default Namespace Instellen

Het steeds typen van `-n namespace` kan vervelend worden. Gelukkig kun je een default namespace instellen voor je huidige context.

## Huidige Context Bekijken

Eerst kijken we naar je huidige kubectl context:

```plain
kubectl config current-context
```{{exec}}

Bekijk ook de volledige context informatie:

```plain
kubectl config get-contexts
```{{exec}}

## Default Namespace Instellen

Stel de webapp namespace in als je default namespace:

```plain
kubectl config set-context --current --namespace=webapp
```{{exec}}

## Test de Nieuwe Default Namespace

Nu kun je pods bekijken zonder de `-n` flag:

```plain
kubectl get pods
```{{exec}}

Je zou nu de pods uit de webapp namespace moeten zien, zonder `-n webapp` te hoeven typen!

Probeer ook andere commando's:

```plain
kubectl get deployments
```{{exec}}

```plain
kubectl get services
```{{exec}}

## Verander naar een Andere Namespace

Laten we de default namespace veranderen naar monitoring:

```plain
kubectl config set-context --current --namespace=monitoring
```{{exec}}

Test dit door pods te bekijken:

```plain
kubectl get pods
```{{exec}}

Nu zie je de monitoring pods!

## Terug naar Default

Je kunt altijd terug naar de originele default namespace:

```plain
kubectl config set-context --current --namespace=default
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Context Management Demonstratie

Je gaat nu demonstreren dat je context management beheerst door een specifieke workflow uit te voeren.

1. **Stel de monitoring namespace in als default**
2. **Maak een pod aan** in de huidige default namespace (monitoring) met de naam `context-test-pod`
3. **Verander de default namespace** naar `development`
4. **Maak een ConfigMap aan** in de nieuwe default namespace met de naam `context-demo`

**Commando's die je nodig hebt:**

```bash
# Stap 1: Stel monitoring als default in
kubectl config set-context --current --namespace=monitoring

# Stap 2: Maak pod aan (zal in monitoring namespace komen)
kubectl run context-test-pod --image=busybox --command -- sleep 3600

# Stap 3: Verander naar development namespace
kubectl config set-context --current --namespace=development

# Stap 4: Maak ConfigMap aan (zal in development namespace komen)
kubectl create configmap context-demo --from-literal=message="Default namespace changed successfully"
```

### Verificatie

De verificatie controleert:
- ✅ Of de `context-test-pod` bestaat in de monitoring namespace
- ✅ Of de `context-demo` ConfigMap bestaat in de development namespace
- ✅ Of je huidige default namespace correct is ingesteld

### Waarom is Dit Handig?

Het instellen van een default namespace is handig omdat:
1. Je minder hoeft te typen
2. Je minder kans hebt op fouten
3. Je efficiënter kunt werken binnen één namespace
4. Scripts en commando's korter worden

**Tip**: Vergeet niet in welke namespace je werkt! Sommige tools tonen dit in je prompt.