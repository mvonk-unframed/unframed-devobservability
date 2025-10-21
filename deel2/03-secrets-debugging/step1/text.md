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

## Wat Zie Je?

Analyseer de output en identificeer:
1. Hoeveel secrets zijn er in totaal?
2. Welke verschillende types zie je?
3. Welke secrets hebben de meeste data keys?
4. Zijn er secrets die recent zijn aangemaakt?

Deze informatie helpt je begrijpen welke credentials beschikbaar zijn in je cluster.