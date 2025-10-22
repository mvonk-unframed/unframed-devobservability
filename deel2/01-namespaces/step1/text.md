# Stap 1: Namespace Concept Begrijpen

## Wat zijn Kubernetes Namespaces?

Namespaces zijn virtuele clusters binnen een fysiek Kubernetes cluster. Ze bieden een manier om resources te organiseren en te isoleren. Denk aan namespaces als verschillende "kamers" in een groot gebouw - elke kamer heeft zijn eigen spullen, maar ze delen dezelfde infrastructuur.

## Waarom Namespaces Gebruiken?

- **Organisatie**: Verschillende klanten of projecten kunnen hun eigen namespace hebben
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
k get ns
```{{exec}}

## Wat zie je?

Je zou verschillende namespaces moeten zien, waaronder de standaard Kubernetes namespaces en enkele custom namespaces die zijn aangemaakt voor deze training.

## 🎯 Praktische Opdracht

Nu ga je je kennis toetsen door een praktische opdracht uit te voeren. Je moet het aantal namespaces tellen en een namespace aanmaken met die naam.

### Opdracht 1: Tel de Namespaces

1. **Voer het commando uit om alle namespaces te bekijken**
2. **Tel het totale aantal namespaces** (inclusief standaard Kubernetes namespaces)
3. **Maak een nieuwe namespace aan** met als naam het aantal namespaces dat je hebt geteld met daarvoor `ns-`

**Voorbeeld:** Als je 8 namespaces ziet, maak dan een namespace aan met de naam `ns-8`:

```bash
# Eerst tellen
kubectl get namespaces
# Tel het aantal (bijvoorbeeld 8)
# Dan namespace aanmaken
kubectl create namespace ns-8
```

**TIP** Gaat het de eerste keer mis, tel dan je zelf aangemaakte namespace mee!