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

## Multiple Choice Vragen

**Vraag 1:** Welke kubectl optie geeft je de meest gedetailleerde informatie over een namespace?

A) `kubectl get namespace -o wide`
B) `kubectl describe namespace <name>`
C) `kubectl get namespace -o yaml`
D) `kubectl get namespace --show-labels`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

`kubectl get namespace -o yaml` geeft de volledige YAML configuratie van een namespace, inclusief alle metadata, labels, annotations, en configuratie details. Dit is de meest uitgebreide output.

- `-o wide` geeft wat extra kolommen
- `describe` geeft een samenvatting in leesbare vorm
- `--show-labels` toont alleen de labels
</details>

---

**Vraag 2:** Wat betekent het als een namespace de status "Active" heeft?

A) Er draaien momenteel pods in deze namespace
B) De namespace is operationeel en kan resources bevatten
C) De namespace wordt automatisch gemonitord
D) De namespace heeft resource quota's ingesteld

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Een "Active" status betekent dat de namespace operationeel is en resources kan bevatten. Het zegt niets over:
- Of er daadwerkelijk pods in draaien
- Of er monitoring is ingesteld
- Of er resource quota's zijn geconfigureerd

Een namespace kan Active zijn maar leeg, of vol met resources.
</details>

---

**Vraag 3:** Welke informatie vind je NIET in de output van `kubectl describe namespace`?

A) Labels en annotations
B) Resource quota's (indien ingesteld)
C) Lijst van alle pods in de namespace
D) Namespace status en age

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

`kubectl describe namespace` toont informatie over de namespace zelf, maar niet de inhoud ervan. Voor een lijst van pods gebruik je:
`kubectl get pods -n <namespace>`

De describe output bevat wel:
- Labels en annotations
- Resource quota's (als die zijn ingesteld)
- Status en creation timestamp
</details>

---

## Wat Leer Je Hiervan?

Door namespaces te beschrijven leer je:
1. Wanneer ze zijn aangemaakt
2. Welke labels en annotations ze hebben
3. Of er resource quota's zijn ingesteld
4. De huidige status van de namespace

Bekijk de verschillende namespaces en probeer te identificeren welke voor welk doel gebruikt worden op basis van hun namen.