# KillerCoda Memorybank - Structuur en Best Practices

## Overzicht
Dit document bevat alle belangrijke informatie over de KillerCoda scenario structuur, gebaseerd op analyse van de bestaande voorbeelden.

## Basis Structuur

### Scenario Map Structuur
Elke scenario heeft zijn eigen map met de volgende bestanden:
- `index.json` - Hoofdconfiguratiebestand
- `intro.md` - Introductie tekst
- `step1.md`, `step2.md`, etc. - Stap bestanden
- `finish.md` - Afsluitende tekst
- `assets/` - Map voor extra bestanden (optioneel)

### index.json Structuur
```json
{
  "title": "Scenario Titel",
  "description": "Beschrijving van het scenario",
  "details": {
    "intro": {
      "text": "intro.md",
      "background": "setup.sh" // optioneel
    },
    "steps": [
      {
        "title": "Stap Titel",
        "text": "step1.md",
        "verify": "verify.sh" // optioneel
      }
    ],
    "finish": {
      "text": "finish.md"
    }
  },
  "backend": {
    "imageid": "ubuntu" // of "kubernetes-kubeadm-1node"
  }
}
```

## Backend Images
- `ubuntu` - Standaard Ubuntu omgeving
- `kubernetes-kubeadm-1node` - Kubernetes cluster met 1 node
- `kubernetes-kubeadm-2nodes` - Kubernetes cluster met 2 nodes

## Stap Bestanden

### Markdown Syntax
- Gebruik `{{exec}}` voor uitvoerbare commando's
- Gebruik code blocks met `plain` voor commando's
- Gebruik `<br>` voor extra witruimte

### Voorbeeld Stap:
```markdown
Create a new file called `my-file`

```plain
touch my-file
```{{exec}}

Check if the file exists:

```plain
ls -la my-file
```{{exec}}
```

## Verificatie Scripts
- Bash scripts die controleren of de gebruiker de stap correct heeft uitgevoerd
- Moeten executable zijn (`#!/bin/bash`)
- Return 0 voor succes, non-zero voor falen

### Voorbeeld verify.sh:
```bash
#!/bin/bash
stat /root/my-file
```

## Multi-Step Scenario's
Voor complexere scenario's kun je mappen gebruiken:
```
scenario-name/
├── index.json
├── intro.md
├── step1/
│   ├── text.md
│   ├── verify.sh
│   ├── foreground.sh (optioneel)
│   └── background.sh (optioneel)
├── step2/
│   ├── text.md
│   └── verify.sh
└── finish.md
```

## Foreground/Background Scripts
- `foreground.sh` - Scripts die zichtbaar voor de gebruiker draaien
- `background.sh` - Scripts die op de achtergrond draaien
- Kunnen per stap of voor de hele intro gebruikt worden

## Assets
- Extra bestanden kunnen in een `assets/` map geplaatst worden
- Worden automatisch beschikbaar gemaakt in de scenario omgeving

## Course Structuur
Voor het groeperen van scenario's in cursussen:
- Gebruik een aparte repository structuur
- Zie: https://github.com/killercoda/scenario-examples-courses

## Best Practices

### Naamgeving
- Gebruik duidelijke, beschrijvende namen voor scenario's
- Gebruik kebab-case voor mapnamen
- Gebruik duidelijke titels in index.json

### Inhoud
- Houd stappen kort en gefocust
- Geef duidelijke instructies
- Gebruik verificatie scripts waar mogelijk
- Voeg uitleg toe bij complexe commando's

### Structuur
- Begin met eenvoudige concepten
- Bouw geleidelijk op in complexiteit
- Gebruik consistente formatting
- Test alle commando's voordat je publiceert

## Geanalyseerde Voorbeelden

### Terminal/Linux Voorbeelden:
- `ubuntu-simple/` - Basis Ubuntu omgeving
- `learning-linux/linux-files-introduction/` - Bestandsbeheer
- `code-snippets/` - Code voorbeelden
- `verification/` - Verificatie voorbeeld

### Kubernetes Voorbeelden:
- `kubernetes-1node/` - Basis Kubernetes
- `kubernetes-2node-multi-step-verification/` - Multi-node setup
- `kubernetes-dashboard/` - Dashboard installatie
- `kubernetes-volumes/` - Volume management
- `network-traffic-kubernetes/` - Netwerk debugging

### Script Voorbeelden:
- `foreground-background-scripts/` - Basis scripts
- `foreground-background-scripts-multi-step/` - Multi-step scripts
- `foreground-background-scripts-multi-step-ide/` - IDE integratie

### Andere:
- `upload-assets/` - Asset management
- `use-images/` - Afbeelding gebruik
- `theia-ide-visual-editor/` - IDE integratie
- `network-traffic/` - Netwerk analyse

## Aanbevelingen voor Nieuwe Scenario's

### Deel 1 - Basis Terminal Kennis
Scenario's die zouden moeten worden opgenomen:
1. Navigatie (cd, ls, pwd)
2. Bestandsbeheer (touch, cp, mv, rm)
3. Tekst bewerking (cat, less, grep, sed)
4. Permissies (chmod, chown)
5. Processen (ps, top, kill)
6. Netwerk basics (ping, curl, wget)

### Deel 2 - Kubernetes Debugging
Scenario's die zouden moeten worden opgenomen:
1. Pod debugging (kubectl logs, describe, exec)
2. Service debugging (endpoints, connectivity)
3. Resource monitoring (top, events)
4. Network troubleshooting
5. Storage issues
6. Configuration debugging