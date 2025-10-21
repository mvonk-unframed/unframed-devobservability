# Gefeliciteerd! 🎉

Je hebt succesvol de Kubernetes Namespaces training voltooid!

## Wat heb je geleerd?

In deze 8 minuten heb je de volgende vaardigheden ontwikkeld:

### 1. Namespace Concepten
- ✅ Begrijpt wat Kubernetes namespaces zijn en waarom ze belangrijk zijn
- ✅ Kent de standaard namespaces (default, kube-system, kube-public)
- ✅ Begrijpt hoe namespaces resource isolatie bieden

### 2. Namespace Navigatie
- ✅ Kunt alle namespaces bekijken met `kubectl get namespaces`
- ✅ Kunt gedetailleerde namespace informatie bekijken met `kubectl describe`
- ✅ Begrijpt namespace metadata en status informatie

### 3. Resource Management per Namespace
- ✅ Kunt resources in specifieke namespaces bekijken met `-n` flag
- ✅ Begrijpt hoe verschillende resource types per namespace zijn georganiseerd
- ✅ Kunt alle resources in een namespace bekijken met `kubectl get all -n`

### 4. Efficiënt Werken met Namespaces
- ✅ Kunt de default namespace instellen met `kubectl config set-context`
- ✅ Begrijpt hoe dit je workflow efficiënter maakt
- ✅ Kunt switchen tussen verschillende namespaces

### 5. Cluster-brede Resource Monitoring
- ✅ Kunt resources across alle namespaces bekijken met `--all-namespaces`
- ✅ Begrijpt hoe je cluster-brede monitoring uitvoert
- ✅ Kunt filteren en zoeken across namespaces

## Belangrijke Commando's die je nu beheerst:

```bash
# Namespace overzicht
kubectl get namespaces
kubectl describe namespace <name>

# Resources per namespace
kubectl get pods -n <namespace>
kubectl get all -n <namespace>

# Default namespace instellen
kubectl config set-context --current --namespace=<namespace>

# Cluster-breed bekijken
kubectl get pods --all-namespaces
kubectl get pods -A
```

## Volgende Stappen

Je bent nu klaar voor meer geavanceerde Kubernetes debugging! In de volgende scenario's ga je leren over:
- Pod status en resource debugging
- Secret management en troubleshooting
- Network connectivity debugging

## Praktische Tips voor de Productie

1. **Gebruik duidelijke namespace namen** die het doel weerspiegelen
2. **Stel altijd je default namespace in** wanneer je langere tijd in één namespace werkt
3. **Gebruik `--all-namespaces`** voor cluster monitoring en troubleshooting
4. **Documenteer je namespace strategie** voor je team

**Goed gedaan! Je bent nu een namespace expert! 🚀**