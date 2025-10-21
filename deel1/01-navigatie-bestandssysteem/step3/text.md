# Stap 3: Navigeren tussen mappen

Nu je de inhoud van je directory kunt zien, is het tijd om te leren hoe je tussen mappen navigeert. Het [`cd`](https://man7.org/linux/man-pages/man1/cd.1p.html) commando (Change Directory) is hiervoor essentieel.

## Basis navigatie

Laten we naar de `documents` map navigeren die in de setup is aangemaakt:

```bash
cd documents
```{{exec}}

Controleer waar je nu bent:

```bash
pwd
```{{exec}}

Bekijk wat er in deze map staat:

```bash
ls -lah
```{{exec}}

## Terug naar de parent directory

Om één niveau omhoog te gaan (naar de parent directory), gebruik je `..`:

```bash
cd ..
```{{exec}}

Controleer weer waar je bent:

```bash
pwd
```{{exec}}

## Handige cd shortcuts

- **`cd`** (zonder argumenten): Ga naar je home directory
- **`cd ~`**: Ook naar je home directory  
- **`cd -`**: Ga terug naar de vorige directory
- **`cd ..`**: Ga één niveau omhoog
- **`cd ../..`**: Ga twee niveaus omhoog

## Opdracht

1. Navigeer naar de `projects` directory
2. Ga dan naar de `web` subdirectory binnen projects
3. Controleer je locatie met [`pwd`](https://man7.org/linux/man-pages/man1/pwd.1.html)

```bash
cd projects/web
pwd
```{{exec}}

Voer deze commando's uit om door te gaan naar de volgende stap.