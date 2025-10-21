# Stap 5: Verificatie van ingestelde rechten

In deze laatste stap gaan we alle wijzigingen die we hebben gemaakt controleren en ervoor zorgen dat alles correct is ingesteld. Dit is een belangrijke stap in systeembeheer - altijd je werk verifiëren!

## Opdracht 1: Overzicht van alle wijzigingen

Laten we een volledig overzicht maken van alle bestanden en hun rechten:

```bash
echo "=== SCRIPTS DIRECTORY ==="
ls -la /home/student/scripts/
```{{exec}}

```bash
echo "=== CONFIG DIRECTORY ==="
ls -la /home/student/config/
```{{exec}}

```bash
echo "=== DOCUMENTS DIRECTORY ==="
ls -la /home/student/documents/
```{{exec}}

```bash
echo "=== SHARED DIRECTORY ==="
ls -la /home/student/shared/
```{{exec}}

```bash
echo "=== BACKUP DIRECTORY ==="
ls -la /home/student/backup/
```{{exec}}

## Opdracht 2: Test script functionaliteit

Controleer of alle scripts daadwerkelijk werken:

```bash
echo "Testing backup script:"
/home/student/scripts/backup.sh
```{{exec}}

```bash
echo "Testing monitor script:"
/home/student/scripts/monitor.sh
```{{exec}}

```bash
echo "Testing Python script:"
/home/student/scripts/process_data.py
```{{exec}}

## Opdracht 3: Beveiligingscontrole

Controleer specifiek de beveiligingsgevoelige bestanden:

```bash
echo "Checking secrets file permissions:"
ls -l /home/student/config/secrets.conf
```{{exec}}

Het secrets bestand zou **600** (rw-------) moeten hebben - alleen de eigenaar kan lezen en schrijven.

## Opdracht 4: Groepsrechten verificatie

Controleer de groepsrechten:

```bash
echo "Checking group memberships:"
groups student
```{{exec}}

```bash
echo "Checking project notes group ownership:"
ls -l /home/student/shared/project_notes.txt
```{{exec}}

## Opdracht 5: Eigendom verificatie

Controleer of alle eigendom correct is ingesteld:

```bash
echo "Checking ownership of key files:"
ls -l /home/student/backup/config.bak
ls -l /home/student/documents/
```{{exec}}

## Opdracht 6: Samenvatting van alle rechten

Maak een overzicht van alle belangrijke bestanden:

```bash
find /home/student -type f -exec ls -l {} \; | grep -E "(scripts|config|documents|shared|backup)" | head -20
```{{exec}}

## Wat zou je moeten zien?

Na alle wijzigingen zouden de rechten er zo uit moeten zien:

### Scripts (alle uitvoerbaar):
- `backup.sh`: `-rwxr-xr-x` (755)
- `monitor.sh`: `-rwxr-xr-x` (755)  
- `process_data.py`: `-rwxr-xr-x` (755)

### Configuratie (beveiligd):
- `secrets.conf`: `-rw-------` (600)
- `database.conf`: `-rw-r--r--` (644)
- `webserver.conf`: `-rw-r--r--` (644)

### Documenten (toegankelijk):
- `readme.txt`: `-rw-r--r--` (644)
- `internal.txt`: `-rw-r--r--` (644)

### Gedeeld (groepsrechten):
- `project_notes.txt`: `-rw-rw-r--` (664) met groep `projectteam`

### Backup (eigendom):
- `config.bak`: eigendom van `student:student`

## Troubleshooting

Als iets niet klopt, gebruik deze commando's om te corrigeren:

```bash
# Script niet uitvoerbaar?
chmod 755 /home/student/scripts/scriptname.sh

# Bestand te open?
chmod 600 /home/student/config/secrets.conf

# Verkeerde eigenaar?
sudo chown student:student /path/to/file

# Verkeerde groep?
sudo chown :projectteam /path/to/file
```

## Belangrijke lessen

Je hebt nu geleerd:
- **Rechten lezen**: Begrijpen van rwx notatie
- **Chmod gebruiken**: Numeriek en symbolisch
- **Eigendom beheren**: chown voor user en group
- **Scripts activeren**: Execute rechten toekennen
- **Beveiliging**: Minimale rechten principe

Controleer alle bestanden en zorg dat alles correct is ingesteld voordat je doorgaat!