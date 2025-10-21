# Pod Status en Resource Debugging

Welkom bij de Pod Debugging training! In dit scenario leer je hoe je pod problemen diagnosticeert en oplost in een Kubernetes cluster.

## Wat ga je leren?

In de volgende 15 minuten ga je:
- Pod status interpretatie en lifecycle begrijpen
- Resource verbruik monitoren met `kubectl top`
- Gedetailleerde pod informatie analyseren
- Pod logs effectief gebruiken voor troubleshooting
- Verschillende pod failure scenario's diagnosticeren

## Waarom is Pod Debugging cruciaal?

Pod debugging is essentieel omdat:
- **Pods zijn de kleinste deployable units** in Kubernetes
- **Applicatie problemen** manifesteren zich vaak op pod niveau
- **Resource constraints** kunnen applicatie performance beïnvloeden
- **Logs bevatten cruciale informatie** voor troubleshooting

## Scenario Context

Je werkt als DevOps engineer en er zijn verschillende problemen gemeld:
- Sommige applicaties starten niet op
- Er zijn performance problemen
- Pods crashen onverwacht
- Resources lijken uitgeput

Het cluster is voorbereid met verschillende pods in verschillende states, inclusief enkele met opzettelijke problemen. Jouw taak is om deze problemen te identificeren en te begrijpen hoe je ze kunt diagnosticeren.

## Veelvoorkomende Pod States

Je gaat kennismaken met verschillende pod states:
- **Running**: Pod draait normaal
- **Pending**: Pod wacht op scheduling of resources
- **CrashLoopBackOff**: Pod crasht herhaaldelijk
- **ImagePullBackOff**: Kan container image niet downloaden
- **OOMKilled**: Pod is gestopt vanwege memory limiet

<br>

**Laten we beginnen met pod debugging!**