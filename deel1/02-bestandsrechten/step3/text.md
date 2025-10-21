# Stap 3: Eigendom wijzigen met chown

Het [`chown`](https://man7.org/linux/man-pages/man1/chown.1.html) commando (change owner) wordt gebruikt om de eigenaar en groep van bestanden te wijzigen. Dit is belangrijk voor toegangsbeheer en beveiliging.

## Syntax

```bash
chown [eigenaar]:[groep] bestand
chown eigenaar bestand          # Alleen eigenaar wijzigen
chown :groep bestand           # Alleen groep wijzigen
chown eigenaar:groep bestand   # Beide wijzigen
```

## Huidige situatie controleren

Eerst bekijken we welke bestanden verkeerde eigenaren hebben:

```bash
ls -l /home/student/config/
```{{exec}}

```bash
ls -l /home/student/backup/
```{{exec}}

Je zult zien dat sommige bestanden eigendom zijn van `root` in plaats van `student`.

## Opdracht 1: Eigendom terugzetten naar student

Het backup bestand moet eigendom zijn van student:

```bash
sudo chown student:student /home/student/backup/config.bak
```{{exec}}

**Opmerking**: We gebruiken `sudo` omdat alleen de huidige eigenaar (root) of een administrator eigendom kan wijzigen.

## Opdracht 2: Groep wijzigen

Verander de groep van het project_notes bestand naar een gedeelde groep. Eerst maken we een groep:

```bash
sudo groupadd projectteam
```{{exec}}

Voeg de student toe aan deze groep:

```bash
sudo usermod -a -G projectteam student
```{{exec}}

Wijzig de groep van het bestand:

```bash
sudo chown :projectteam /home/student/shared/project_notes.txt
```{{exec}}

## Opdracht 3: Recursief eigendom wijzigen

Zorg ervoor dat alle bestanden in de documents directory eigendom zijn van student:

```bash
sudo chown -R student:student /home/student/documents/
```{{exec}}

De `-R` flag betekent recursief - het wijzigt eigendom van alle bestanden en subdirectories.

## Verificatie

Controleer de wijzigingen:

```bash
ls -l /home/student/backup/config.bak
```{{exec}}

```bash
ls -l /home/student/shared/project_notes.txt
```{{exec}}

```bash
ls -l /home/student/documents/
```{{exec}}

## Waarom is eigendom belangrijk?

- **Beveiliging**: Alleen de juiste gebruikers hebben toegang
- **Samenwerking**: Groepen kunnen bestanden delen
- **Systeembeheer**: Duidelijke verantwoordelijkheden
- **Backup/Restore**: Behoud van oorspronkelijke eigendom

## Belangrijke opmerkingen

- Alleen root of de huidige eigenaar kan eigendom wijzigen
- Gebruik `sudo` voor administratieve wijzigingen
- De `-R` flag werkt recursief op directories
- Groepen moeten bestaan voordat je ze kunt toewijzen

Voer alle chown commando's uit om door te gaan naar de volgende stap.