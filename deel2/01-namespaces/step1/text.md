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

Bekijk de output en identificeer:
1. Welke namespaces zijn standaard Kubernetes namespaces?
2. Welke namespaces zijn custom aangemaakt voor applicaties?