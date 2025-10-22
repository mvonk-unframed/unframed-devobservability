# Stap 1: Secrets Overzicht

## Wat zijn Kubernetes Secrets?

Secrets zijn Kubernetes objecten die gevoelige informatie opslaan zoals passwords, OAuth tokens, SSH keys, en TLS certificates. Ze zijn vergelijkbaar met ConfigMaps, maar specifiek ontworpen voor confidentiële data.

## Bekijk Alle Secrets

Laten we beginnen met het bekijken van alle secrets in de secrets namespace:

```plain
kubectl get secrets -n secrets
```{{exec}}

## Secret Types Begrijpen

Je zult verschillende types secrets zien:

### Opaque Secrets
Dit zijn algemene secrets voor custom data:

```plain
kubectl get secrets -n secrets --field-selector type=Opaque
```{{exec}}

### TLS Secrets
Voor SSL/TLS certificates:

```plain
kubectl get secrets -n secrets --field-selector type=kubernetes.io/tls
```{{exec}}

### Docker Registry Secrets
Voor container registry authenticatie:

```plain
kubectl get secrets -n secrets --field-selector type=kubernetes.io/dockerconfigjson
```{{exec}}

## Gedetailleerde Secret Informatie

Voor meer details over alle secrets:

```plain
kubectl get secrets -n secrets -o wide
```{{exec}}

## Secret Age en Metadata

Bekijk wanneer secrets zijn aangemaakt:

```plain
kubectl get secrets -n secrets --sort-by=.metadata.creationTimestamp
```{{exec}}

## Vergelijking met ConfigMaps

Ter vergelijking, bekijk ook ConfigMaps (voor non-sensitive data):

```plain
kubectl get configmaps -n secrets
```{{exec}}

## Belangrijke Observaties

Let op de volgende aspecten in de output:
1. **NAME**: De naam van de secret
2. **TYPE**: Het type secret (Opaque, TLS, etc.)
3. **DATA**: Aantal key-value pairs in de secret
4. **AGE**: Hoe lang de secret al bestaat

## Security Opmerking

**Belangrijk**: Secrets zijn base64 encoded, NIET encrypted! Ze bieden obfuscation maar geen echte encryptie. Voor echte encryptie heb je tools zoals SOPS nodig (wat we later behandelen).

## Multiple Choice Vragen

**Vraag 1:** Wat is het belangrijkste verschil tussen Secrets en ConfigMaps?

A) Secrets zijn groter dan ConfigMaps
B) Secrets zijn base64 encoded, ConfigMaps zijn plain text
C) ConfigMaps kunnen alleen strings bevatten
D) Secrets zijn sneller dan ConfigMaps

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Het belangrijkste verschil:
- **Secrets**: Base64 encoded (obfuscation, geen echte encryptie)
- **ConfigMaps**: Plain text

Secrets zijn ontworpen voor gevoelige data zoals passwords, tokens, en certificates. ConfigMaps zijn voor non-sensitive configuratie data.
</details>

---

**Vraag 2:** Welk secret type wordt gebruikt voor SSL/TLS certificates?

A) Opaque
B) kubernetes.io/tls
C) kubernetes.io/dockerconfigjson
D) kubernetes.io/service-account-token

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Secret types:
- **kubernetes.io/tls**: Voor SSL/TLS certificates (bevat tls.crt en tls.key)
- **Opaque**: Algemene secrets voor custom data
- **kubernetes.io/dockerconfigjson**: Voor Docker registry authenticatie
- **kubernetes.io/service-account-token**: Voor service account tokens
</details>

---

**Vraag 3:** Wat betekent het DATA veld in de secret output?

A) De grootte van de secret in bytes
B) Het aantal key-value pairs in de secret
C) Het aantal pods dat de secret gebruikt
D) De datum waarop de secret is aangemaakt

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Het DATA veld toont het aantal key-value pairs in de secret. Bijvoorbeeld:
- DATA: 3 betekent dat de secret 3 verschillende keys bevat
- DATA: 1 betekent dat de secret 1 key bevat

De waarden zelf zijn niet zichtbaar in de lijst output voor security redenen.
</details>

---

## Wat Zie Je?

Analyseer de output en identificeer:
1. Hoeveel secrets zijn er in totaal?
2. Welke verschillende types zie je?
3. Welke secrets hebben de meeste data keys?
4. Zijn er secrets die recent zijn aangemaakt?

Deze informatie helpt je begrijpen welke credentials beschikbaar zijn in je cluster.