# SOPS Secret Management

Welkom bij de SOPS Secret Management training! In dit scenario leer je hoe je encrypted secrets beheert met SOPS voor veilige secret management.

## Wat ga je leren?

In de volgende 10 minuten ga je:
- SOPS concept en voordelen begrijpen
- Encrypted secrets decrypten en bekijken
- Secrets veilig bewerken met SOPS editor
- Nieuwe secrets encrypten en toepassen
- Secret rotation workflows implementeren

## Waarom SOPS gebruiken?

SOPS (Secrets OPerationS) lost belangrijke problemen op:
- **Git Security**: Secrets veilig opslaan in Git repositories
- **Encryption at Rest**: Echte encryptie in plaats van base64 encoding
- **Team Collaboration**: Meerdere mensen kunnen encrypted secrets bewerken
- **Key Management**: Ondersteuning voor verschillende encryption backends
- **Audit Trail**: Git history toont wie wat heeft gewijzigd

## SOPS vs Kubernetes Secrets

| Aspect | Kubernetes Secrets | SOPS |
|--------|-------------------|------|
| **Encoding** | Base64 (niet encrypted) | Echte encryptie |
| **Git Storage** | ❌ Onveilig | ✅ Veilig |
| **Key Management** | Handmatig | Geautomatiseerd |
| **Team Access** | RBAC only | Encryption keys + RBAC |
| **Audit** | Kubernetes events | Git history |

## Scenario Context

Je werkt als DevOps engineer en je team wil:
- Secrets veilig opslaan in Git repositories
- Geautomatiseerde secret rotation implementeren
- Compliance vereisten voor encryption at rest naleven
- Team members toegang geven tot specifieke secrets

Het cluster is voorbereid met SOPS tooling en encrypted secret files. Je gaat leren hoe je deze tools gebruikt voor veilige secret management in een productie omgeving.

## SOPS Encryption Backends

SOPS ondersteunt verschillende encryption backends:
- **Age**: Moderne, eenvoudige encryptie (aanbevolen)
- **GPG**: Traditionele PGP encryptie
- **AWS KMS**: Amazon Key Management Service
- **Azure Key Vault**: Microsoft Azure encryptie
- **GCP KMS**: Google Cloud Key Management

## Security Voordelen

Met SOPS krijg je:
- **Encryption at Rest**: Secrets zijn altijd encrypted in Git
- **Selective Encryption**: Alleen secret waarden, metadata blijft leesbaar
- **Key Rotation**: Eenvoudige key rotation zonder secret re-encryption
- **Access Control**: Granulaire controle over wie welke secrets kan bewerken

<br>

**Laten we beginnen met SOPS secret management!**