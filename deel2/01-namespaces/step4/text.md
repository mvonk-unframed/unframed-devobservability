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

## Waarom is Dit Handig?

Het instellen van een default namespace is handig omdat:
1. Je minder hoeft te typen
2. Je minder kans hebt op fouten
3. Je efficiënter kunt werken binnen één namespace
4. Scripts en commando's korter worden

**Tip**: Vergeet niet in welke namespace je werkt! Sommige tools tonen dit in je prompt.