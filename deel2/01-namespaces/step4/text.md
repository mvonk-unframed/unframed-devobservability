# Stap 4: Default Namespace Instellen

Het steeds typen van `-n namespace` kan vervelend worden. Gelukkig kun je een default namespace instellen voor je huidige context.

## Huidige Context Bekijken

Eerst kijken we naar je huidige kubectl context:

```plain
kubectl config current-context
```{{exec}}

Bekijk ook de volledige context informatie:

```plain
kubectl config get-contexts
```{{exec}}

## Default Namespace Instellen

Stel de webapp namespace in als je default namespace:

```plain
kubectl config set-context --current --namespace=webapp
```{{exec}}

## Test de Nieuwe Default Namespace

Nu kun je pods bekijken zonder de `-n` flag:

```plain
kubectl get pods
```{{exec}}

Je zou nu de pods uit de webapp namespace moeten zien, zonder `-n webapp` te hoeven typen!

Probeer ook andere commando's:

```plain
kubectl get deployments
```{{exec}}

```plain
kubectl get services
```{{exec}}

## Verander naar een Andere Namespace

Laten we de default namespace veranderen naar monitoring:

```plain
kubectl config set-context --current --namespace=monitoring
```{{exec}}

Test dit door pods te bekijken:

```plain
kubectl get pods
```{{exec}}

Nu zie je de monitoring pods!

## Terug naar Default

Je kunt altijd terug naar de originele default namespace:

```plain
kubectl config set-context --current --namespace=default
```{{exec}}

## Multiple Choice Vragen

**Vraag 1:** Welk commando stelt de "webapp" namespace in als je default namespace?

A) `kubectl set namespace webapp`
B) `kubectl config set-context --current --namespace=webapp`
C) `kubectl use namespace webapp`
D) `kubectl default namespace webapp`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Het correcte commando is:
`kubectl config set-context --current --namespace=webapp`

Dit wijzigt je huidige kubectl context om de webapp namespace als default te gebruiken. Hierna kun je kubectl commando's uitvoeren zonder de `-n` flag.
</details>

---

**Vraag 2:** Wat gebeurt er nadat je een default namespace hebt ingesteld?

A) Alle namespaces worden samengevoegd
B) Je kunt alleen nog resources in die namespace bekijken
C) Kubectl commando's gebruiken automatisch die namespace tenzij je `-n` specificeert
D) De andere namespaces worden verborgen

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

Na het instellen van een default namespace:
- Kubectl commando's gebruiken automatisch die namespace
- Je kunt nog steeds andere namespaces benaderen met `-n <namespace>`
- Je kunt nog steeds `--all-namespaces` gebruiken
- Andere namespaces blijven gewoon bestaan en toegankelijk

Het is gewoon een gemak om niet steeds `-n` te hoeven typen.
</details>

---

**Vraag 3:** Hoe kun je controleren welke namespace momenteel je default is?

A) `kubectl get namespace`
B) `kubectl config current-context`
C) `kubectl config get-contexts`
D) `kubectl config view --minify`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: C**

`kubectl config get-contexts` toont alle contexts en markeert de huidige context met een `*`. In de NAMESPACE kolom zie je welke namespace is ingesteld als default.

- `kubectl config current-context` toont alleen de context naam
- `kubectl config view --minify` toont de volledige config maar is minder overzichtelijk
- `kubectl get namespace` toont alle namespaces maar niet welke de default is
</details>

---

## Waarom is Dit Handig?

Het instellen van een default namespace is handig omdat:
1. Je minder hoeft te typen
2. Je minder kans hebt op fouten
3. Je efficiënter kunt werken binnen één namespace
4. Scripts en commando's korter worden

**Tip**: Vergeet niet in welke namespace je werkt! Sommige tools tonen dit in je prompt.