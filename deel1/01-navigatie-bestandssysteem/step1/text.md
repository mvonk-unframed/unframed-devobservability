# Stap 1: Huidige locatie bepalen

Als systeembeheerder is het belangrijk om altijd te weten waar je je bevindt in het bestandssysteem. Het [`pwd`](https://man7.org/linux/man-pages/man1/pwd.1.html) commando (Print Working Directory) toont je huidige locatie.

## Opdracht

Gebruik het [`pwd`](https://man7.org/linux/man-pages/man1/pwd.1.html) commando om je huidige locatie te bepalen:

```bash
pwd
```{{exec}}

## Wat zie je?

Je zou iets moeten zien zoals `/home/student` of `/root`. Dit is je huidige werkdirectory.

## Waarom is dit belangrijk?

- Je weet altijd waar je commando's worden uitgevoerd
- Relatieve paden zijn gebaseerd op deze locatie
- Het voorkomt dat je per ongeluk bestanden in de verkeerde map bewerkt

Voer het [`pwd`](https://man7.org/linux/man-pages/man1/pwd.1.html) commando uit om door te gaan naar de volgende stap.