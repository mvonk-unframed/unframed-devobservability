# Stap 2: Directory inhoud bekijken

Nu je weet waar je bent, is het tijd om te zien wat er in je huidige directory staat. Het [`ls`](https://man7.org/linux/man-pages/man1/ls.1.html) commando toont de inhoud van een directory.

## De krachtige ls -lah combinatie

We gebruiken [`ls -lah`](https://man7.org/linux/man-pages/man1/ls.1.html) voor de meest informatieve weergave:

- **`-l`**: Lange lijst met details (permissions, eigenaar, grootte, datum)
- **`-a`**: Toon alle bestanden (inclusief verborgen bestanden die beginnen met .)
- **`-h`**: Human-readable bestandsgroottes (KB, MB, GB in plaats van bytes)

## Opdracht

Bekijk de inhoud van je huidige directory:

```bash
ls -lah
```{{exec}}

## Wat zie je?

Je zou verschillende kolommen moeten zien:
1. **Permissions** (bijv. `drwxr-xr-x` voor directories, `-rw-r--r--` voor bestanden)
2. **Links** (aantal hard links)
3. **Eigenaar** (gebruiker)
4. **Groep** 
5. **Grootte** (in human-readable formaat)
6. **Datum/tijd** (laatste wijziging)
7. **Naam** (bestand of directory naam)

## Extra tip

Probeer ook eens [`ls -la`](https://man7.org/linux/man-pages/man1/ls.1.html) zonder de `-h` om het verschil te zien:

```bash
ls -la
```{{exec}}

Voer [`ls -lah`](https://man7.org/linux/man-pages/man1/ls.1.html) uit om door te gaan.