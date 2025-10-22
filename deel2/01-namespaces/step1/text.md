# Stap 1: Namespace Concept Begrijpen

## Wat zijn Kubernetes Namespaces?

Namespaces zijn virtuele clusters binnen een fysiek Kubernetes cluster. Ze bieden een manier om resources te organiseren en te isoleren. Denk aan namespaces als verschillende "kamers" in een groot gebouw - elke kamer heeft zijn eigen spullen, maar ze delen dezelfde infrastructuur.

## Waarom Namespaces Gebruiken?

- **Organisatie**: Verschillende teams of projecten kunnen hun eigen namespace hebben
- **Isolatie**: Resources in verschillende namespaces kunnen niet direct met elkaar communiceren
- **Resource Management**: Je kunt quota's en limits instellen per namespace
- **Security**: RBAC policies kunnen per namespace worden toegepast

## Default Namespaces

Kubernetes heeft standaard enkele namespaces:
- `default` - Voor resources zonder specifieke namespace
- `kube-system` - Voor Kubernetes systeem componenten
- `kube-public` - Voor publiek toegankelijke resources
- `kube-node-lease` - Voor node heartbeat informatie

## Je Eerste Namespace Commando

Laten we beginnen met het bekijken van alle namespaces in het cluster:

```plain
kubectl get namespaces
```{{exec}}

Je kunt ook de korte versie gebruiken:

```plain
kubectl get ns
```{{exec}}

## Wat zie je?

Je zou verschillende namespaces moeten zien, waaronder de standaard Kubernetes namespaces en enkele custom namespaces die zijn aangemaakt voor deze training.

## Multiple Choice Vraag

**Vraag 1:** Welke van de volgende namespaces zijn standaard Kubernetes namespaces die automatisch worden aangemaakt?

A) `default`, `webapp`, `database`
B) `kube-system`, `kube-public`, `kube-node-lease`
C) `monitoring`, `secrets`, `network`
D) `frontend`, `backend`, `kube-system`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

De standaard Kubernetes namespaces zijn:
- `kube-system` - Voor Kubernetes systeem componenten
- `kube-public` - Voor publiek toegankelijke resources
- `kube-node-lease` - Voor node heartbeat informatie
- `default` - Voor resources zonder specifieke namespace

Namespaces zoals `webapp`, `database`, `monitoring`, `secrets`, `network`, `frontend`, en `backend` zijn custom namespaces die zijn aangemaakt voor specifieke applicaties of doeleinden.
</details>

---

**Vraag 2:** Wat is het hoofddoel van namespaces in Kubernetes?

A) Om pods sneller te laten opstarten
B) Om resources te organiseren en te isoleren
C) Om meer storage ruimte te creëren
D) Om de netwerksnelheid te verhogen

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Namespaces bieden:
- **Organisatie**: Verschillende teams of projecten kunnen hun eigen namespace hebben
- **Isolatie**: Resources in verschillende namespaces kunnen niet direct met elkaar communiceren
- **Resource Management**: Je kunt quota's en limits instellen per namespace
- **Security**: RBAC policies kunnen per namespace worden toegepast
</details>

---

## Praktische Oefening

Bekijk de output van de commando's hierboven en identificeer:
1. Welke namespaces zijn standaard Kubernetes namespaces?
2. Welke namespaces zijn custom aangemaakt voor applicaties?