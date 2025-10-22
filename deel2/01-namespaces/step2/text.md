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
kubectl describe namespace monitoring
```{{exec}}

## Namespace Status Begrijpen

Let op de volgende velden in de output:
- **Status**: Toont of de namespace actief is
- **Age**: Hoe lang de namespace al bestaat
- **Labels**: Metadata labels die aan de namespace zijn toegevoegd
- **Annotations**: Extra metadata informatie
- **Resource Quotas**: Hoeveel mag deze namespace maximaal verbruiken

## 🎯 Praktische Opdracht

### Opdracht: Namespace Labels en Analyse

Je gaat nu labels toevoegen aan namespaces en een analyse maken.

1. **Voeg een label toe** aan de webapp namespace met key `purpose` en value `frontend`
   **Tip!** gebruik kubectl om info in te winnen `kubectl label namespace --help` 
2. **Quota verhogen** voeg een quota toe aan de webapp namespace van 1gb en 1cpu
   **Tip!** gebruik kubectl om info in te winnen `kubectl create quota --help`

### Wat Leer Je Hiervan?

Door namespaces te beschrijven en labelen leer je:
1. Wanneer ze zijn aangemaakt
2. Welke labels en annotations ze hebben
3. Of er resource quota's zijn ingesteld
4. De huidige status van de namespace
5. Hoe je metadata kunt toevoegen voor organisatie