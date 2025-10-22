# Stap 4: Pod Logs Analyseren

## Waarom Logs Essentieel Zijn

Logs bevatten de meest gedetailleerde informatie over wat er in je applicatie gebeurt. Ze zijn onmisbaar voor het diagnosticeren van applicatie-specifieke problemen.

## Basis Log Commando's

Bekijk logs van een werkende pod:

```plain
kubectl logs -n debugging -l app=healthy-app
```{{exec}}

## Logs van een Specifieke Pod

Vind eerst een specifieke pod en bekijk de logs:

```plain
kubectl get pods -n debugging -l app=healthy-app -o name | head -1 | xargs kubectl logs -n debugging
```{{exec}}

## Real-time Log Streaming

Voor real-time logs gebruik je de `-f` (follow) flag:

```plain
kubectl logs -f -n debugging -l app=crash-app --tail=10
```{{exec}}

**Druk Ctrl+C om te stoppen met volgen**

## Previous Container Logs

Wanneer een container crasht, kun je de logs van de vorige instantie bekijken:

```plain
kubectl logs -n debugging -l app=crash-app --previous
```{{exec}}

Dit is cruciaal voor het debuggen van CrashLoopBackOff problemen!

## Logs van Multi-Container Pods

Als een pod meerdere containers heeft, specificeer de container:

```plain
kubectl get pods -n debugging -o jsonpath='{.items[0].spec.containers[*].name}'
```{{exec}}

## Logs Filteren en Zoeken

Gebruik grep om specifieke informatie te vinden:

```plain
kubectl logs -n debugging -l app=healthy-app | grep -i error
```{{exec}}

Zoek naar warnings:

```plain
kubectl logs -n debugging -l app=healthy-app | grep -i warn
```{{exec}}

## Logs met Timestamps

Voor debugging is timing belangrijk:

```plain
kubectl logs -n debugging -l app=crash-app --timestamps
```{{exec}}

## Beperkte Log Output

Bekijk alleen de laatste regels:

```plain
kubectl logs -n debugging -l app=crash-app --tail=20
```{{exec}}

## Logs van Alle Containers in een Pod

Voor pods met meerdere containers:

```plain
kubectl logs -n debugging -l app=healthy-app --all-containers=true
```{{exec}}

## Praktische Log Analyse

### Voor CrashLoopBackOff:
1. Bekijk huidige logs: `kubectl logs <pod>`
2. Bekijk previous logs: `kubectl logs <pod> --previous`
3. Zoek naar error messages en exit codes

### Voor Performance Problemen:
1. Gebruik `--timestamps` om timing te analyseren
2. Zoek naar slow queries of timeouts
3. Monitor met `-f` voor real-time analyse

### Voor Startup Problemen:
1. Bekijk logs vanaf het begin
2. Zoek naar initialization errors
3. Check dependency connections

## 🎯 Praktische Opdracht

### Opdracht: Log Analyse en Error Identificatie

Je gaat nu logs analyseren om de oorzaken van pod problemen te vinden.

1. **Analyseer logs van een CrashLoopBackOff pod**:
   - Bekijk zowel huidige als previous logs
   - Identificeer de error message die de crash veroorzaakt

2. **Maak een Secret aan** met de naam `log-analysis` die je bevindingen documenteert:

```bash
kubectl create secret generic log-analysis \
  --from-literal=crash-pod="<pod-naam>" \
  --from-literal=error-message="<error-uit-logs>" \
  --from-literal=restart-count="<aantal-restarts>"
```

3. **Zoek een pod met veel log output** en maak een ConfigMap aan met de naam `log-stats`:

```bash
kubectl create configmap log-stats \
  --from-literal=verbose-pod="<pod-naam>" \
  --from-literal=log-lines="<aantal-regels-laatste-50>"
```

### Bonus Opdracht: Multi-container Log Analyse

Als er multi-container pods zijn, analyseer deze en maak een Secret aan met de naam `container-analysis`:

```bash
kubectl create secret generic container-analysis \
  --from-literal=multi-pod="<pod-naam>" \
  --from-literal=container-count="<aantal-containers>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je logs kunt analyseren en error messages kunt vinden
- ✅ Of je previous logs kunt bekijken voor crashed containers
- ✅ Of je multi-container pod logs kunt onderscheiden

**Tip**: Gebruik [`kubectl logs <pod> --previous -n debugging`](kubectl logs <pod> --previous -n debugging) voor crashed containers!