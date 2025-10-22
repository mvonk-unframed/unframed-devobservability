# Stap 2: Secret Decrypten met SOPS

## SOPS Decrypt Commando

De basis van SOPS is het kunnen decrypten van encrypted files. Laten we beginnen met het decrypten van de database credentials:

```plain
sops -d /root/secrets/database-secret.yaml
```{{exec}}

## API Keys Decrypten

Bekijk de gedecodeerde API keys:

```plain
sops -d /root/secrets/api-keys-secret.yaml
```{{exec}}

## TLS Certificate Decrypten

Decrypt het TLS certificate secret:

```plain
sops -d /root/secrets/tls-secret.yaml
```{{exec}}

## Specifieke Waarden Extraheren

Je kunt ook specifieke waarden uit encrypted files halen met `--extract`:

```plain
sops -d --extract '["data"]["username"]' /root/secrets/database-secret.yaml
```{{exec}}

Haal de database password op:

```plain
sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml
```{{exec}}

## Base64 Decodering Combineren

Combineer SOPS decrypt met base64 decodering om de echte waarde te zien:

```plain
sops -d --extract '["data"]["username"]' /root/secrets/database-secret.yaml | base64 -d
```{{exec}}

```plain
sops -d --extract '["data"]["password"]' /root/secrets/database-secret.yaml | base64 -d
```{{exec}}

## JSON Output voor Processing

Voor scripting kun je JSON output gebruiken:

```plain
sops -d --output-type json /root/secrets/api-keys-secret.yaml | jq '.data'
```{{exec}}

## Vergelijking met Plain Secret

Vergelijk met een niet-encrypted secret:

```plain
cat /root/secrets/plain-secret.yaml
```{{exec}}

## SOPS Metadata Bekijken

Bekijk alleen de SOPS metadata zonder te decrypten:

```plain
sops -d --extract '["sops"]' /root/secrets/database-secret.yaml
```{{exec}}

## Encryption Status Controleren

Controleer of een file encrypted is:

```plain
sops filestatus /root/secrets/database-secret.yaml
```{{exec}}

```plain
sops filestatus /root/secrets/plain-secret.yaml
```{{exec}}

## Rotation Secret Decrypten

Bekijk het rotation demo secret:

```plain
sops -d /root/secrets/rotation-secret.yaml
```{{exec}}

## Praktische Use Cases

### 1. **Debugging Credentials**
```bash
# Snel een password checken
sops -d --extract '["data"]["password"]' secret.yaml | base64 -d
```

### 2. **Script Integration**
```bash
# Gebruik in scripts
DB_PASSWORD=$(sops -d --extract '["data"]["password"]' secret.yaml | base64 -d)
```

### 3. **CI/CD Pipelines**
```bash
# Deploy secrets in pipelines
sops -d secret.yaml | kubectl apply -f -
```

## Security Voordelen van Decrypt

1. **On-demand Decryption**: Secrets worden alleen gedecodeerd wanneer nodig
2. **No Persistent Storage**: Gedecodeerde waarden worden niet opgeslagen
3. **Audit Trail**: SOPS kan loggen wie wanneer wat heeft gedecodeerd
4. **Key Access Control**: Alleen mensen met de juiste keys kunnen decrypten

## Wat Zie Je?

Analyseer de output en let op:
1. **Metadata Preservation**: Kubernetes metadata blijft intact
2. **Selective Encryption**: Alleen `data` velden zijn encrypted
3. **SOPS Metadata**: Encryption informatie aan het einde
4. **Base64 Encoding**: Data is nog steeds base64 encoded na decryptie

## Multiple Choice Vragen

**Vraag 1:** Welk commando decrypteert een SOPS encrypted file?

A) `sops --decrypt file.yaml`
B) `sops -d file.yaml`
C) `sops decrypt file.yaml`
D) `kubectl decrypt file.yaml`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Het correcte commando is `sops -d file.yaml`:
- `-d` is de korte versie van `--decrypt`
- Dit toont de gedecodeerde inhoud op stdout
- De originele file blijft encrypted

`kubectl decrypt` bestaat niet - dat is een SOPS functie.
</details>

---

**Vraag 2:** Hoe extraheer je een specifieke waarde uit een encrypted secret?

A) `sops -d file.yaml | grep key`
B) `sops -d --extract '["data"]["key"]' file.yaml`
C) `sops --get key file.yaml`
D) `sops -d file.yaml --key key`

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

`sops -d --extract '["data"]["key"]' file.yaml` extraheert een specifieke waarde:
- `--extract` gebruikt JSONPath syntax
- Handig voor scripting en automation
- Geeft alleen de gevraagde waarde terug

De andere opties bestaan niet of zijn minder efficiënt.
</details>

---

**Vraag 3:** Wat moet je doen na SOPS decryptie om de echte secret waarde te zien?

A) Niets, de waarde is al leesbaar
B) Base64 decoderen met `| base64 -d`
C) JSON parsing met jq
D) URL decoding

<details>
<summary>Klik hier voor het antwoord</summary>

**Correct antwoord: B**

Na SOPS decryptie zijn Kubernetes secret waarden nog steeds base64 encoded:
1. SOPS decrypteert de encrypted waarden
2. Maar Kubernetes secrets gebruiken base64 encoding
3. Dus je moet nog `| base64 -d` gebruiken voor de echte waarde

SOPS decrypteert alleen de SOPS encryptie, niet de Kubernetes base64 encoding.
</details>

---

## Troubleshooting Decrypt Issues

Als decrypt faalt, controleer:
1. **Key File**: Is `SOPS_AGE_KEY_FILE` correct ingesteld?
2. **Key Access**: Heb je toegang tot de juiste encryption key?
3. **File Integrity**: Is het encrypted file niet corrupt?
4. **SOPS Version**: Zijn er versie incompatibiliteiten?

Je kunt nu encrypted secrets veilig decrypten en de inhoud bekijken!