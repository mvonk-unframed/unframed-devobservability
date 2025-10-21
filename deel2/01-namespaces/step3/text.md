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

## Wat Leer Je?

Door resources per namespace te bekijken, zie je:
1. Hoe applicaties zijn georganiseerd
2. Welke componenten bij elkaar horen
3. Hoe namespace isolatie werkt in de praktijk
4. De relatie tussen verschillende resource types

Let op hoe elke namespace zijn eigen set van pods, deployments en services heeft!