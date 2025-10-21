# Secrets en Credentials Debugging

Welkom bij de Secrets Debugging training! In dit scenario leer je hoe je secret management en credential troubleshooting uitvoert in Kubernetes.

## Wat ga je leren?

In de volgende 12 minuten ga je:
- Kubernetes secrets begrijpen en bekijken
- Secret details en configuratie analyseren
- Secret inhoud decoderen en interpreteren
- Pod-secret verbindingen identificeren
- Credential gerelateerde problemen troubleshooten

## Waarom is Secret Management cruciaal?

Secret management is essentieel omdat:
- **Security**: Gevoelige informatie moet veilig opgeslagen worden
- **Credential Management**: Database passwords, API keys, certificates
- **Configuration**: Applicatie configuratie die niet in code hoort
- **Troubleshooting**: Veel applicatie problemen zijn credential gerelateerd

## Scenario Context

Je werkt als DevOps engineer en er zijn verschillende problemen gemeld:
- Een web applicatie kan niet verbinden met de database
- API calls falen vanwege authentication issues
- Certificates lijken verlopen of incorrect
- Applicaties kunnen hun configuratie niet laden

Het cluster is voorbereid met verschillende secrets en applicaties die deze gebruiken. Sommige secrets hebben opzettelijke problemen. Jouw taak is om te leren hoe je secret gerelateerde problemen kunt identificeren en diagnosticeren.

## Kubernetes Secret Types

Je gaat kennismaken met verschillende secret types:
- **Opaque**: Algemene secrets (passwords, API keys)
- **kubernetes.io/dockerconfigjson**: Docker registry credentials
- **kubernetes.io/tls**: TLS certificates en keys
- **kubernetes.io/service-account-token**: Service account tokens

## Secret Security Principes

Belangrijke principes die je gaat leren:
- Secrets zijn base64 encoded (niet encrypted!)
- Secrets worden gemount als files of environment variables
- RBAC controleert wie secrets kan bekijken
- Secret rotation is belangrijk voor security

<br>

**Laten we beginnen met secret debugging!**