# Stap 2: Resource Verbruik Controleren

## Waarom Resource Monitoring Belangrijk Is

Resource problemen zijn een van de meest voorkomende oorzaken van pod failures. Te weinig CPU of memory kan leiden tot poor performance of crashes.

## Node Resource Status

Eerst bekijken we de resource status van de nodes:

```plain
kubectl top nodes
```{{exec}}

Dit toont:
- **CPU**: Huidige CPU gebruik per node
- **MEMORY**: Huidige memory gebruik per node
- **CPU%** en **MEMORY%**: Percentage van totale capaciteit

## Pod Resource Verbruik

Bekijk het resource verbruik van alle pods:

```plain
kubectl top pods -n debugging
```{{exec}}

## Sorteer Pods op Resource Verbruik

Sorteer pods op CPU verbruik (hoogste eerst):

```plain
kubectl top pods -n debugging --sort-by=cpu
```{{exec}}

Sorteer pods op memory verbruik:

```plain
kubectl top pods -n debugging --sort-by=memory
```{{exec}}

## Cluster-breed Resource Overzicht

Voor een volledig overzicht van alle pods in het cluster:

```plain
kubectl top pods --all-namespaces --sort-by=memory
```{{exec}}

## Resource Requests en Limits Bekijken

Om te zien welke resource requests en limits zijn ingesteld:

```plain
kubectl get pods -n debugging -o custom-columns=NAME:.metadata.name,CPU-REQ:.spec.containers[*].resources.requests.cpu,MEM-REQ:.spec.containers[*].resources.requests.memory,CPU-LIM:.spec.containers[*].resources.limits.cpu,MEM-LIM:.spec.containers[*].resources.limits.memory
```{{exec}}

## Resource Problemen Identificeren

Let op de volgende signalen:
1. **Hoog CPU/Memory verbruik**: Kan performance problemen veroorzaken
2. **Pods die hun limits benaderen**: Risico op throttling (CPU) of OOMKill (memory)
3. **Nodes met hoog verbruik**: Kan scheduling problemen veroorzaken

## Wat Betekenen de Metrics?

- **CPU**: Gemeten in millicores (m). 1000m = 1 CPU core
- **Memory**: Gemeten in bytes (Ki, Mi, Gi)
- **Requests**: Gegarandeerde resources
- **Limits**: Maximum toegestane resources

## Multiple Choice Vragen

**Vraag 1:** Wat betekent "1000m" in CPU metrics?

A) 1000 megabytes
B) 1 CPU core
C) 1000 milliseconden
D) 1000 memory units

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

CPU wordt gemeten in millicores (m):
- 1000m = 1 CPU core
- 500m = 0.5 CPU core
- 100m = 0.1 CPU core

Dit is een standaard manier om CPU resources te specificeren in Kubernetes.
</details>

---

**Vraag 2:** Wat is het verschil tussen resource "requests" en "limits"?

A) Requests zijn maximaal, limits zijn minimaal
B) Requests zijn gegarandeerde resources, limits zijn maximum toegestaan
C) Ze betekenen hetzelfde
D) Requests zijn voor CPU, limits zijn voor memory

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

- **Requests**: Gegarandeerde resources die de pod krijgt (gebruikt voor scheduling)
- **Limits**: Maximum resources dat de pod mag gebruiken

Als een pod zijn CPU limit overschrijdt wordt het "throttled". Als het zijn memory limit overschrijdt wordt het "OOMKilled".
</details>

---

**Vraag 3:** Welk commando toont pods gesorteerd op memory verbruik?

A) `kubectl top pods --sort-by=memory`
B) `kubectl get pods --sort-by=memory`
C) `kubectl top pods --order-by=memory`
D) `kubectl describe pods --sort-memory`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: A**

`kubectl top pods --sort-by=memory` sorteert pods op memory verbruik van laag naar hoog.

Je kunt ook sorteren op:
- `--sort-by=cpu` voor CPU verbruik
- `--sort-by=name` voor pod naam

Let op: `kubectl top` vereist dat metrics-server draait in het cluster.
</details>

---

## Praktische Analyse

Analyseer de output en identificeer:
1. Welke pods gebruiken de meeste CPU?
2. Welke pods gebruiken de meeste memory?
3. Zijn er pods die hun limits benaderen?
4. Zijn er nodes die overbelast zijn?

**Tip**: Als `kubectl top` niet werkt, is metrics-server mogelijk nog niet klaar. Wacht een paar minuten en probeer opnieuw.