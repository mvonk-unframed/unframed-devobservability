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

## Wat Leer Je Hiervan?

Door namespaces te beschrijven leer je:
1. Wanneer ze zijn aangemaakt
2. Welke labels en annotations ze hebben
3. Of er resource quota's zijn ingesteld
4. De huidige status van de namespace

Bekijk de verschillende namespaces en probeer te identificeren welke voor welk doel gebruikt worden op basis van hun namen.