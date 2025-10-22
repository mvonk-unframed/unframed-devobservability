# Stap 5: Debugging Scenario's

## Praktische Debugging Workflow

Pas je geleerde technieken toe op echte problemen.

## Debugging Stappen

Voor elk probleem volg je deze workflow:

1. **Identificeer**: `kubectl get pods -n debugging`
2. **Analyseer**: `kubectl describe pod <naam> -n debugging`
3. **Logs**: `kubectl logs <naam> -n debugging --previous`

## Veelvoorkomende Problemen

Bekijk alle problematische pods:

```plain
kubectl get pods -n debugging | grep -E "(ImagePullBackOff|Pending|CrashLoopBackOff|0/)"
```{{exec}}

### ImagePullBackOff
```plain
kubectl get pods -n debugging -o name | grep broken-image | head -1 | xargs kubectl describe -n debugging
```{{exec}}

### Resource Problemen (Pending)
```plain
kubectl get pods -n debugging -o name | grep resource-hungry | head -1 | xargs kubectl describe -n debugging
```{{exec}}

### Crashes (CrashLoopBackOff)
```plain
kubectl logs -n debugging -l app=crash-app --previous
```{{exec}}

## Resource Usage Controleren

```plain
kubectl top pods -n debugging --sort-by=memory
```{{exec}}

## 🎯 Opdracht

Documenteer alle gevonden problemen in een Secret:

```bash
kubectl create secret generic debugging-report \
  --from-literal=imagepull-issue="<verkeerde-image-naam>" \
  --from-literal=pending-issue="<resource-constraint>" \
  --from-literal=crash-issue="<crash-reden>" \
  --from-literal=oom-limit="<memory-limit-waarde>"
```

Maak ook een ConfigMap met de debugging workflow:

```bash
kubectl create configmap debugging-workflow \
  --from-literal=step1="kubectl get pods" \
  --from-literal=step2="kubectl describe pod" \
  --from-literal=step3="kubectl logs pod" \
  --from-literal=step4="kubectl logs pod --previous"
```

## Probleem Cheatsheet

| Status | Oorzaak | Check |
|--------|---------|-------|
| ImagePullBackOff | Verkeerde image | Events in describe |
| Pending | Geen resources | Events + resource requests |
| CrashLoopBackOff | App crash | Logs --previous |
| 0/1 Ready | Health check faalt | Events + logs |

**Je beheerst nu pod debugging!**