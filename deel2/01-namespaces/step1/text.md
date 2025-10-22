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

## 🎯 Praktische Opdracht

Nu ga je je kennis toetsen door een praktische opdracht uit te voeren. Je moet het aantal namespaces tellen en een namespace aanmaken met die naam.

### Opdracht 1: Tel de Namespaces

1. **Voer het commando uit om alle namespaces te bekijken**
2. **Tel het totale aantal namespaces** (inclusief standaard Kubernetes namespaces)
3. **Maak een nieuwe namespace aan** met als naam het aantal namespaces dat je hebt geteld

**Voorbeeld:** Als je 8 namespaces ziet, maak dan een namespace aan met de naam `ns-8`:

```bash
kubectl create namespace ns-8
```

### Opdracht 2: Identificeer Standaard Namespaces

Bekijk de output van [`kubectl get namespaces`](kubectl get namespaces) en identificeer:

1. **Standaard Kubernetes namespaces** (beginnen meestal met `kube-` of zijn `default`)
2. **Custom namespaces** (aangemaakt voor specifieke applicaties)

### Verificatie

Je opdracht wordt automatisch gecontroleerd. De verificatie controleert:
- ✅ Of je de namespace commando's hebt uitgevoerd
- ✅ Of je een namespace hebt aangemaakt met het juiste aantal
- ✅ Of alle verwachte namespaces bestaan

**Tip:** Gebruik [`kubectl get ns`](kubectl get ns) als afkorting voor `kubectl get namespaces`