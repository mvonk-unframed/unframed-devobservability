# Deel 1 - Basis Terminal Kennis Ontwerp

## Overzicht
Cursisten worden binnen 30 minuten getoetst op essentiële Linux terminal vaardigheden.

## Scenario Structuur

### 1. Navigatie en Bestandssysteem Verkenning
**Map:** `deel1/01-navigatie-bestandssysteem/`
**Tijd:** ~5 minuten
**Doel:** Beheersing van basis navigatie en systeem informatie

#### Stappen:
1. **Huidige locatie bepalen** - `pwd` commando
2. **Directory inhoud bekijken** - `ls -lah` voor gedetailleerde listing
3. **Navigeren tussen mappen** - `cd` naar verschillende locaties
4. **Schijfruimte controleren** - `df -h` voor filesystem usage
5. **Directory grootte** - `du -sh` voor folder sizes

#### Verificatie:
- Controleer of gebruiker in juiste directory staat
- Verificeer dat ze de juiste bestanden kunnen vinden
- Test begrip van output van `ls -lah`

### 2. Bestandsrechten en Eigendom
**Map:** `deel1/02-bestandsrechten/`
**Tijd:** ~6 minuten
**Doel:** Begrip en manipulatie van file permissions

#### Stappen:
1. **Rechten lezen** - Uitleg van rwx notatie in `ls -l` output
2. **Rechten wijzigen** - `chmod` met numerieke en symbolische notatie
3. **Eigendom wijzigen** - `chown` voor user:group wijzigingen
4. **Praktische oefening** - Script executable maken
5. **Verificatie** - Controleren van ingestelde rechten

#### Verificatie:
- Test of bestand juiste permissions heeft (bijv. 755)
- Controleer eigendom wijzigingen
- Verificeer dat script uitvoerbaar is

### 3. Processen Beheren
**Map:** `deel1/03-processen-beheren/`
**Tijd:** ~6 minuten
**Doel:** Process management en monitoring

#### Stappen:
1. **Actieve processen bekijken** - `ps aux` en `ps -ef`
2. **Real-time monitoring** - `top` en `htop` basics
3. **Processen zoeken** - `ps aux | grep <naam>`
4. **Processen beëindigen** - `kill <PID>` en `kill -9 <PID>`
5. **Processen per naam killen** - `pkill <naam>` en `killall <naam>`
6. **Praktische oefening** - Runaway process stoppen

#### Verificatie:
- Test of gebruiker processen kan identificeren
- Controleer of ze processen veilig kunnen beëindigen
- Verificeer begrip van verschillende kill signals

### 4. Tekst Editors
**Map:** `deel1/04-tekst-editors/`
**Tijd:** ~4 minuten
**Doel:** Basis bestandsbewerking

#### Stappen:
1. **Nano basics** - Bestand openen, bewerken, opslaan
2. **Vi/Vim essentials** - Insert mode, save & quit (:wq)
3. **Praktische oefening** - Config bestand aanpassen

#### Verificatie:
- Controleer of bestand correct is aangepast
- Test of gebruiker kan navigeren in beide editors

### 5. Bestanden Bekijken en Zoeken
**Map:** `deel1/05-bestanden-bekijken/`
**Tijd:** ~5 minuten
**Doel:** Efficiënt werken met bestandsinhoud

#### Stappen:
1. **Bestand inhoud tonen** - `cat` voor kleine bestanden
2. **Grote bestanden** - `less` en `head`/`tail`
3. **Zoeken in bestanden** - `grep` basis en `grep -E` voor regex
4. **Praktische oefening** - Log bestanden doorzoeken

#### Verificatie:
- Test of juiste regels gevonden worden met grep
- Verificeer begrip van regex patterns

### 6. Pipes en Data Processing
**Map:** `deel1/06-pipes-processing/`
**Tijd:** ~4 minuten
**Doel:** Geavanceerde command chaining

#### Scenario Setup:
- Log bestand met IP adressen, timestamps, en status codes
- Netwerk configuratie bestanden

#### Stappen:
1. **Pipe basics** - Combineren van commando's met `|`
2. **IP adressen extraheren** - `grep -E` voor IP pattern matching
3. **Sorteren** - `sort` en `sort -n` voor numeriek
4. **Unieke waarden** - `uniq -c` voor counting
5. **Praktische opdracht** - Top 5 meest voorkomende IP's vinden

#### Voorbeeld Opdracht:
```bash
# Vind de top 5 IP adressen in access.log
cat access.log | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | sort -nr | head -5
```

#### Verificatie:
- Controleer of juiste IP adressen gevonden zijn
- Test begrip van pipe chain logica

## Technische Implementatie

### Backend Configuration:
```json
{
  "backend": {
    "imageid": "ubuntu"
  }
}
```

### Pre-setup Scripts:
Elk scenario krijgt een `setup.sh` die:
- Test bestanden aanmaakt
- Log bestanden genereert met realistische data
- Directories en permissions instelt
- Sample configuratie bestanden plaatst

### Verificatie Strategie:
- Elke stap heeft een `verify.sh` script
- Controleert niet alleen het eindresultaat maar ook de gebruikte methode
- Geeft hints bij fouten

### Voorbeeld Setup Script:
```bash
#!/bin/bash
# Setup voor navigatie scenario

# Maak test directory structuur
mkdir -p /home/student/{documents,downloads,projects/web,projects/scripts}

# Maak test bestanden met verschillende groottes
echo "Small file content" > /home/student/documents/readme.txt
dd if=/dev/zero of=/home/student/downloads/largefile.dat bs=1M count=10

# Stel verschillende permissions in
chmod 644 /home/student/documents/readme.txt
chmod 755 /home/student/projects/scripts/
```

## Tijdsindeling per Scenario:
1. Navigatie: 5 min
2. Bestandsrechten: 6 min
3. Processen beheren: 6 min
4. Tekst editors: 4 min
5. Bestanden bekijken: 5 min
6. Pipes & processing: 4 min

**Totaal: 30 minuten**

## Leeruitkomsten:
Na afloop kunnen cursisten:
- Efficiënt navigeren door het bestandssysteem
- Bestandsrechten lezen en aanpassen
- Processen monitoren en beheren (ps, top, kill, pkill)
- Basis tekstbewerking uitvoeren
- Bestanden doorzoeken met grep en regex
- Complexe data processing met pipes uitvoeren