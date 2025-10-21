# Stap 1: Rechten lezen en begrijpen

Bestandsrechten in Linux worden weergegeven in een specifiek formaat. Het [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html) commando toont gedetailleerde informatie over bestanden, inclusief hun rechten.

## Opdracht

Bekijk de rechten van alle bestanden in de `/home/student` directory:

```bash
ls -l /home/student
```{{exec}}

En bekijk ook de subdirectories:

```bash
ls -l /home/student/scripts
```{{exec}}

```bash
ls -l /home/student/config
```{{exec}}

## Rechten begrijpen

De output ziet er zo uit:
```
-rwxr-xr-- 1 student student 1024 Dec 15 10:30 example.sh
```

Laten we dit ontleden:

### Bestandstype en rechten (eerste 10 karakters):
- **Eerste karakter**: Bestandstype
  - `-` = gewoon bestand
  - `d` = directory
  - `l` = symbolische link
  
- **Volgende 9 karakters**: Rechten in groepen van 3
  - **rwx** (posities 2-4): Eigenaar rechten
  - **r-x** (posities 5-7): Groep rechten  
  - **r--** (posities 8-10): Andere gebruikers rechten

### Rechten betekenis:
- **r** (read): Lezen toegestaan
- **w** (write): Schrijven toegestaan
- **x** (execute): Uitvoeren toegestaan
- **-**: Recht niet toegekend

## Numerieke waarden

Elke rechtencombinatie heeft ook een numerieke waarde:
- **r** = 4
- **w** = 2  
- **x** = 1

Bijvoorbeeld: `rwx` = 4+2+1 = 7, `r-x` = 4+0+1 = 5, `r--` = 4+0+0 = 4

Dus `rwxr-xr--` = **754**

## Wat zie je?

Kijk naar de output en identificeer:
1. Welke bestanden zijn uitvoerbaar?
2. Welke bestanden kan alleen de eigenaar schrijven?
3. Zijn er bestanden die te open of te restrictief lijken?

Voer de [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html) commando's uit om door te gaan.