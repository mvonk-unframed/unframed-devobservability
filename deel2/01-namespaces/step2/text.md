# Stap 2: Alle Namespaces Bekijken

Nu je het basis concept van namespaces begrijpt, gaan we dieper in op het verkennen van namespaces en hun eigenschappen.

## Gedetailleerde Namespace Informatie

Voor meer gedetailleerde informatie over namespaces kun je de `-o wide` optie gebruiken:

```plain
kubectl get namespaces -o wide
```{{exec}}

## Namespace Details Bekijken

Je kunt ook gedetailleerde informatie over een specifieke namespace bekijken:

```plain
kubectl describe namespace webapp
```{{exec}}

Probeer ook eens de database namespace:

```plain
kubectl describe namespace database
```{{exec}}

## Namespace Status Begrijpen

Let op de volgende velden in de output:
- **Status**: Toont of de namespace actief is
- **Age**: Hoe lang de namespace al bestaat
- **Labels**: Metadata labels die aan de namespace zijn toegevoegd
- **Annotations**: Extra metadata informatie

## YAML Output Bekijken

Voor de volledige configuratie van een namespace kun je YAML output gebruiken:

```plain
kubectl get namespace monitoring -o yaml
```{{exec}}

## 🎯 Praktische Opdracht

### Opdracht: Namespace Labels Toevoegen

Je gaat nu labels toevoegen aan namespaces om te laten zien dat je begrijpt hoe je namespace metadata kunt beheren.

1. **Bekijk de webapp namespace in YAML formaat** en zoek naar de `labels` sectie
2. **Voeg een label toe** aan de webapp namespace met key `purpose` en value `frontend`
3. **Voeg een label toe** aan de database namespace met key `purpose` en value `backend`

**Commando's die je nodig hebt:**

```bash
# Label toevoegen aan namespace
kubectl label namespace webapp purpose=frontend

# Label toevoegen aan database namespace
kubectl label namespace database purpose=backend
```

### Verificatie Opdracht

Maak een ConfigMap aan in de `default` namespace met de naam `namespace-analysis` die de volgende informatie bevat:

- **total-namespaces**: Het totale aantal namespaces
- **custom-namespaces**: Het aantal custom namespaces (niet-standaard)

**Voorbeeld:**
```bash
kubectl create configmap namespace-analysis \
  --from-literal=total-namespaces=8 \
  --from-literal=custom-namespaces=5
```

### Wat Leer Je Hiervan?

Door namespaces te beschrijven en labelen leer je:
1. Wanneer ze zijn aangemaakt
2. Welke labels en annotations ze hebben
3. Of er resource quota's zijn ingesteld
4. De huidige status van de namespace
5. Hoe je metadata kunt toevoegen voor organisatie

**Tip:** Gebruik [`kubectl get namespace --show-labels`](kubectl get namespace --show-labels) om alle labels te zien!