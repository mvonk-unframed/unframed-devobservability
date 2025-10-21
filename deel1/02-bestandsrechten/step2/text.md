# Stap 2: Rechten wijzigen met chmod

Het [`chmod`](https://man7.org/linux/man-pages/man1/chmod.1.html) commando (change mode) wordt gebruikt om bestandsrechten te wijzigen. Er zijn twee manieren: numeriek en symbolisch.

## Numerieke methode

Gebruik cijfers om rechten in te stellen:
- **4** = read (r)
- **2** = write (w)  
- **1** = execute (x)

Tel deze op voor elke groep (eigenaar, groep, anderen):
- **7** = rwx (4+2+1)
- **6** = rw- (4+2+0)
- **5** = r-x (4+0+1)
- **4** = r-- (4+0+0)

## Opdracht 1: Beveilig het secrets bestand

Het bestand `/home/student/config/secrets.conf` is momenteel te open (777). Maak het alleen leesbaar voor de eigenaar:

```bash
chmod 600 /home/student/config/secrets.conf
```{{exec}}

Controleer het resultaat:

```bash
ls -l /home/student/config/secrets.conf
```{{exec}}

## Opdracht 2: Maak readme publiek leesbaar

Het bestand `/home/student/documents/readme.txt` is te restrictief. Maak het leesbaar voor iedereen:

```bash
chmod 644 /home/student/documents/readme.txt
```{{exec}}

## Symbolische methode

Je kunt ook symbolische notatie gebruiken:
- **u** = user (eigenaar)
- **g** = group (groep)
- **o** = others (anderen)
- **a** = all (iedereen)

Operatoren:
- **+** = rechten toevoegen
- **-** = rechten wegnemen
- **=** = rechten instellen

## Opdracht 3: Gebruik symbolische notatie

Maak het shared project bestand schrijfbaar voor de groep:

```bash
chmod g+w /home/student/shared/project_notes.txt
```{{exec}}

Verwijder write rechten voor others:

```bash
chmod o-w /home/student/shared/project_notes.txt
```{{exec}}

Controleer het resultaat:

```bash
ls -l /home/student/shared/project_notes.txt
```{{exec}}

## Wat heb je geleerd?

- **Numerieke chmod**: `chmod 644 bestand` (rw-r--r--)
- **Symbolische chmod**: `chmod u+x bestand` (voeg execute toe voor user)
- **Beveiligingsprincipe**: Geef alleen de minimaal benodigde rechten

Voer alle chmod commando's uit om door te gaan naar de volgende stap.