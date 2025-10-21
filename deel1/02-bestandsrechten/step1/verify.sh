#!/bin/bash

# Verificatie voor stap 1: ls -l commando voor rechten lezen
# Controleer of de gebruiker de ls -l commando's heeft uitgevoerd

# Check of ls -l in de command history staat
if history | grep -q "ls -l"; then
    echo "✅ Goed gedaan! Je hebt het ls -l commando gebruikt om bestandsrechten te bekijken."
    
    # Extra check voor specifieke directories
    if history | grep -q "ls -l /home/student"; then
        echo "✅ Perfect! Je hebt ook de student directory bekeken."
    fi
    
    if history | grep -q "ls -l /home/student/scripts\|ls -l /home/student/config"; then
        echo "✅ Uitstekend! Je hebt ook de subdirectories onderzocht."
    fi
    
    echo ""
    echo "💡 Tip: Let op de verschillende rechten die je ziet:"
    echo "   - Scripts die nog niet uitvoerbaar zijn (geen 'x')"
    echo "   - Configuratiebestanden met verschillende beveiligingsniveaus"
    echo "   - Bestanden met verschillende eigenaren"
    
    exit 0
else
    echo "❌ Het lijkt erop dat je het ls -l commando nog niet hebt uitgevoerd."
    echo "💡 Tip: Gebruik 'ls -l /home/student' om de bestandsrechten te bekijken."
    echo "💡 Probeer ook: 'ls -l /home/student/scripts' en 'ls -l /home/student/config'"
    exit 1
fi