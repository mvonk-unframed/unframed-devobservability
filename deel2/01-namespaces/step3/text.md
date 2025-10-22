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

## Multiple Choice Vragen

**Vraag 1:** Welk commando toont alle pods in de "webapp" namespace?

A) `kubectl get pods webapp`
B) `kubectl get pods -n webapp`
C) `kubectl get pods --namespace webapp`
D) Zowel B als C zijn correct

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: D**

Beide opties zijn correct:
- `-n webapp` is de korte versie
- `--namespace webapp` is de lange versie

Ze doen precies hetzelfde. De `-n` flag is een afkorting van `--namespace`.
</details>

---

**Vraag 2:** Wat toont het commando `kubectl get all -n webapp`?

A) Alleen pods in de webapp namespace
B) Alle namespaces die "webapp" in de naam hebben
C) Alle standaard resources (pods, services, deployments, etc.) in de webapp namespace
D) Alle resources in alle namespaces

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

`kubectl get all -n webapp` toont alle standaard Kubernetes resources in de webapp namespace, zoals:
- Pods
- Services
- Deployments
- ReplicaSets
- Jobs (indien aanwezig)

Het toont NIET alle resource types (zoals secrets, configmaps, etc.) en ook niet resources uit andere namespaces.
</details>

---

**Vraag 3:** Waarom zou je resources per namespace organiseren?

A) Om de prestaties van Kubernetes te verbeteren
B) Om applicatie-componenten logisch te groeperen en te isoleren
C) Om minder disk ruimte te gebruiken
D) Om pods sneller te laten opstarten

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Namespace organisatie biedt:
- **Logische groepering**: Gerelateerde componenten bij elkaar
- **Isolatie**: Resources kunnen niet direct cross-namespace communiceren
- **Resource management**: Quota's en limits per namespace
- **Security**: RBAC policies per namespace
- **Team separation**: Verschillende teams kunnen eigen namespaces hebben

Het heeft geen direct effect op prestaties, disk ruimte of opstarttijden.
</details>

---

## Wat Leer Je?

Door resources per namespace te bekijken, zie je:
1. Hoe applicaties zijn georganiseerd
2. Welke componenten bij elkaar horen
3. Hoe namespace isolatie werkt in de praktijk
4. De relatie tussen verschillende resource types

Let op hoe elke namespace zijn eigen set van pods, deployments en services heeft!