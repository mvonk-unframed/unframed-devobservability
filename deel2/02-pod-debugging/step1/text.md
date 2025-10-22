# Stap 1: Pod Status Overzicht

## Pod Lifecycle Begrijpen

Pods hebben verschillende states tijdens hun lifecycle. Het begrijpen van deze states is cruciaal voor effectieve debugging.

## Bekijk Alle Pods in de Debugging Namespace

Laten we beginnen met het bekijken van alle pods in de debugging namespace:

```plain
kubectl get pods -n debugging
```{{exec}}

## Pod Status Interpretatie

Je zult verschillende statussen zien. Hier is wat ze betekenen:

### Normale States:
- **Running**: Pod draait normaal en alle containers zijn gestart
- **Succeeded**: Pod heeft zijn taak voltooid (meestal voor Jobs)
- **Pending**: Pod wacht op scheduling of resources

### Probleem States:
- **CrashLoopBackOff**: Pod crasht herhaaldelijk en Kubernetes probeert het opnieuw
- **ImagePullBackOff**: Kan de container image niet downloaden
- **Error**: Pod is gestopt vanwege een fout
- **OOMKilled**: Pod is gestopt vanwege memory limiet overschrijding

## Gedetailleerde Status Bekijken

Voor meer details over de pod status:

```plain
kubectl get pods -n debugging -o wide
```{{exec}}

Dit toont extra informatie zoals:
- **NODE**: Op welke node de pod draait
- **NOMINATED NODE**: Voor pending pods
- **READINESS GATES**: Custom readiness checks

## Pod Status met Timestamps

Om te zien hoe lang pods in hun huidige state zijn:

```plain
kubectl get pods -n debugging --sort-by=.metadata.creationTimestamp
```{{exec}}

## Multiple Choice Vragen

**Vraag 1:** Wat betekent de pod status "CrashLoopBackOff"?

A) De pod is succesvol gestart en draait normaal
B) De pod crasht herhaaldelijk en Kubernetes probeert het steeds opnieuw
C) De pod wacht op een beschikbare node
D) De pod kan de container image niet downloaden

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

"CrashLoopBackOff" betekent dat:
- De pod crasht herhaaldelijk
- Kubernetes probeert automatisch de pod opnieuw te starten
- Er is een exponential backoff tussen restart pogingen
- Dit duidt meestal op een probleem in de applicatie code of configuratie
</details>

---

**Vraag 2:** Wat is het verschil tussen READY en STATUS kolommen?

A) Ze betekenen hetzelfde
B) READY toont hoeveel containers klaar zijn, STATUS toont de lifecycle state
C) READY is voor services, STATUS is voor pods
D) STATUS is belangrijker dan READY

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

- **READY**: Toont hoeveel containers ready zijn (bijv. 1/1 = 1 van 1 containers ready)
- **STATUS**: Toont de huidige lifecycle state (Running, Pending, CrashLoopBackOff, etc.)

Een pod kan "Running" status hebben maar "0/1 Ready" als de readiness probe faalt!
</details>

---

**Vraag 3:** Welke pod status duidt op een probleem met het downloaden van de container image?

A) CrashLoopBackOff
B) Pending
C) ImagePullBackOff
D) OOMKilled

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

"ImagePullBackOff" betekent dat Kubernetes de container image niet kan downloaden. Dit kan komen door:
- Verkeerde image naam of tag
- Ontbrekende authenticatie voor private registries
- Netwerk problemen
- Image bestaat niet in de registry
</details>

---

## Wat Zie Je?

Analyseer de output en identificeer:
1. Welke pods draaien normaal (Running)?
2. Welke pods hebben problemen?
3. Welke error states zie je?
4. Hoe lang zijn de pods al in hun huidige state?

## Ready vs Status

Let op het verschil tussen **READY** en **STATUS**:
- **READY**: Hoeveel containers ready zijn (bijv. 1/1)
- **STATUS**: De huidige lifecycle state van de pod

Een pod kan **Running** zijn maar **0/1 Ready** als de readiness probe faalt!