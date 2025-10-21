# Bestandsrechten en Eigendom

Welkom bij de tweede oefening in Linux terminal kennis! In deze oefening leer je hoe je bestandsrechten leest, begrijpt en beheert in Linux.

## Wat ga je leren?

- Bestandsrechten lezen en interpreteren met [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html)
- Rechten wijzigen met [`chmod`](https://man7.org/linux/man-pages/man1/chmod.1.html) (numeriek en symbolisch)
- Eigendom wijzigen met [`chown`](https://man7.org/linux/man-pages/man1/chown.1.html)
- Scripts executable maken
- Verificatie van ingestelde rechten

## Scenario

Je bent systeembeheerder en hebt verschillende bestanden en scripts ontvangen van ontwikkelaars. Deze hebben verschillende rechten nodig:
- Sommige bestanden moeten alleen leesbaar zijn
- Scripts moeten uitvoerbaar worden gemaakt
- Bepaalde configuratiebestanden moeten beveiligd worden
- Eigendom moet worden aangepast voor verschillende gebruikers

## Waarom is dit belangrijk?

Bestandsrechten zijn cruciaal voor:
- **Beveiliging**: Voorkomen dat onbevoegden bestanden kunnen wijzigen
- **Functionaliteit**: Scripts moeten uitvoerbaar zijn om te werken
- **Samenwerking**: Juiste eigendom zorgt voor goede toegang
- **Compliance**: Voldoen aan beveiligingsrichtlijnen

**Tijd:** ~6 minuten

Laten we beginnen met het begrijpen van bestandsrechten!