# Stap 4: Pod Logs Bekijken

## Logs - De Applicatie Stem

Logs tonen wat er in je applicatie gebeurt en zijn essentieel voor debugging.

## Basis Log Commando's

Bekijk logs van een pod:

```plain
kubectl logs -n debugging -l app=healthy-app
```{{exec}}

## Real-time Logs Volgen

Voor live logs gebruik `-f`:

```plain
kubectl logs -f -n debugging -l app=crash-app --tail=10
```{{exec}}

**Druk Ctrl+C om te stoppen**

## Previous Logs (Belangrijk!)

Voor crashed containers bekijk de vorige logs:

```plain
kubectl logs -n debugging -l app=crash-app --previous
```{{exec}}

Dit is cruciaal voor CrashLoopBackOff debugging!

## Logs Filteren

Zoek naar errors:

```plain
kubectl logs -n debugging -l app=healthy-app | grep -i error
```{{exec}}

## Nuttige Log Opties

- `--timestamps`: Toon tijdstempels
- `--tail=20`: Laatste 20 regels
- `--previous`: Vorige container instantie

## 🎯 Opdracht

Analyseer logs van crashed pods en documenteer je bevindingen:

```bash
kubectl create secret generic log-analysis \
  --from-literal=crash-pod="<pod-naam>" \
  --from-literal=error-message="<error-uit-logs>" \
  --from-literal=restart-count="<aantal-restarts>"
```

**Tip**: Voor crashed pods gebruik altijd `--previous` om de crash reden te zien!