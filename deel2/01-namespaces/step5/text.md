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

## Multiple Choice Vragen

**Vraag 1:** Welke twee commando's doen hetzelfde (tonen alle pods in alle namespaces)?

A) `kubectl get pods --all-namespaces` en `kubectl get pods -A`
B) `kubectl get pods -n all` en `kubectl get pods --all-namespaces`
C) `kubectl get pods *` en `kubectl get pods -A`
D) `kubectl get all pods` en `kubectl get pods --all-namespaces`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: A**

`kubectl get pods --all-namespaces` en `kubectl get pods -A` zijn identiek:
- `--all-namespaces` is de lange versie
- `-A` is de korte versie (afkorting van --all-namespaces)

De andere opties bestaan niet of werken niet zoals beschreven.
</details>

---

**Vraag 2:** Wat is het voordeel van `kubectl get pods -A | grep nginx` boven `kubectl get pods -n webapp | grep nginx`?

A) Het is sneller
B) Het zoekt naar nginx pods in alle namespaces, niet alleen webapp
C) Het geeft meer gedetailleerde informatie
D) Het is veiliger

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

`kubectl get pods -A | grep nginx` zoekt naar nginx pods in het hele cluster (alle namespaces), terwijl `kubectl get pods -n webapp | grep nginx` alleen zoekt in de webapp namespace.

Dit is handig wanneer je niet weet in welke namespace een specifieke pod draait, of wanneer je alle instanties van een applicatie wilt vinden.
</details>

---

**Vraag 3:** Wanneer zou je `kubectl get all --all-namespaces` gebruiken?

A) Voor dagelijkse monitoring van een specifieke applicatie
B) Voor een volledig cluster overzicht tijdens troubleshooting
C) Voor het bekijken van secrets en configmaps
D) Voor het instellen van resource limits

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

`kubectl get all --all-namespaces` geeft een volledig overzicht van alle standaard resources in het hele cluster. Dit is vooral handig voor:
- Troubleshooting cluster-brede problemen
- Algemene cluster health checks
- Overzicht krijgen van alle draaiende applicaties

Let op: dit commando toont NIET alle resource types (zoals secrets, configmaps) en kan veel output genereren, dus het is niet geschikt voor dagelijkse monitoring van specifieke applicaties.
</details>

---

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