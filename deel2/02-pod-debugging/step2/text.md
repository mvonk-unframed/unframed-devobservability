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

## Praktische Analyse

Analyseer de output en identificeer:
1. Welke pods gebruiken de meeste CPU?
2. Welke pods gebruiken de meeste memory?
3. Zijn er pods die hun limits benaderen?
4. Zijn er nodes die overbelast zijn?

**Tip**: Als `kubectl top` niet werkt, is metrics-server mogelijk nog niet klaar. Wacht een paar minuten en probeer opnieuw.