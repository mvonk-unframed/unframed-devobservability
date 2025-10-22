# Stap 2: Secret Details Bekijken

## Gedetailleerde Secret Informatie

Nu je een overzicht hebt van alle secrets, gaan we dieper in op het bekijken van secret details en configuratie.

## Beschrijf een Secret

Gebruik `kubectl describe` om gedetailleerde informatie te krijgen:

```plain
kubectl describe secret database-credentials -n secrets
```{{exec}}

## Secret Configuratie in YAML

Voor de volledige configuratie gebruik je YAML output:

```plain
kubectl get secret database-credentials -n secrets -o yaml
```{{exec}}

## TLS Secret Details

Bekijk de TLS certificate secret:

```plain
kubectl describe secret webapp-tls -n secrets
```{{exec}}

En de YAML configuratie:

```plain
kubectl get secret webapp-tls -n secrets -o yaml
```{{exec}}

## Docker Registry Secret

Bekijk de Docker registry credentials:

```plain
kubectl describe secret docker-credentials -n secrets
```{{exec}}

## Secret Keys Bekijken

Om alleen de keys (zonder waarden) te zien:

```plain
kubectl get secret database-credentials -n secrets -o jsonpath='{.data}' | jq 'keys'
```{{exec}}

Als `jq` niet beschikbaar is, gebruik dan:

```plain
kubectl get secret database-credentials -n secrets -o jsonpath='{.data}' | grep -o '"[^"]*":'
```{{exec}}

## Secret Metadata Analyseren

Bekijk labels en annotations:

```plain
kubectl get secret database-credentials -n secrets -o jsonpath='{.metadata}'
```{{exec}}

## Vergelijking met ConfigMap

Ter vergelijking, bekijk een ConfigMap:

```plain
kubectl describe configmap app-config -n secrets
```{{exec}}

```plain
kubectl get configmap app-config -n secrets -o yaml
```{{exec}}

## Belangrijke Velden in Secret Details

### In `kubectl describe`:
- **Type**: Het secret type
- **Data**: Aantal en namen van keys (waarden zijn verborgen)
- **Used by**: Welke pods gebruiken dit secret (indien van toepassing)

### In YAML output:
- **apiVersion**: Kubernetes API versie
- **kind**: Resource type (Secret)
- **metadata**: Labels, annotations, namespace
- **type**: Secret type
- **data**: Base64 encoded waarden
- **stringData**: Plain text waarden (alleen bij aanmaken)

## Security Observaties

Let op deze belangrijke aspecten:
1. **Data is base64 encoded** - niet encrypted!
2. **Describe toont geen waarden** - alleen key namen
3. **YAML toont encoded waarden** - deze kunnen gedecodeerd worden
4. **Metadata is niet encrypted** - labels en annotations zijn zichtbaar

## 🎯 Praktische Opdracht

### Opdracht: Secret Metadata Analyse

Je gaat nu secret metadata analyseren en de structuur begrijpen.

1. **Analyseer een TLS secret** en identificeer de key namen
2. **Vergelijk een Opaque secret** met een ConfigMap
3. **Maak een Secret aan** met de naam `secret-metadata` die je analyse bevat:

```bash
kubectl create secret generic secret-metadata \
  --from-literal=tls-keys="<key-namen-gescheiden-door-komma>" \
  --from-literal=opaque-vs-configmap="<verschil-dat-je-ziet>"
```

### Verificatie

De verificatie controleert:
- ✅ Of je secret metadata kunt analyseren
- ✅ Of je verschillende secret types begrijpt
- ✅ Of je het verschil met ConfigMaps kent

**Tip**: Zoek uit hoe je alleen key namen kunt extraheren zonder de waarden te zien!