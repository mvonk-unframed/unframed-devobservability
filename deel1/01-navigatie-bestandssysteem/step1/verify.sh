#!/bin/bash

# Verificatie voor stap 1: pwd commando
# Controleer of de gebruiker het pwd commando heeft uitgevoerd

# Check of pwd in de command history staat
if history | grep -q "pwd"; then
    echo "✅ Goed gedaan! Je hebt het pwd commando gebruikt."
    exit 0
else
    echo "❌ Het lijkt erop dat je het pwd commando nog niet hebt uitgevoerd."
    echo "💡 Tip: Typ 'pwd' en druk op Enter om je huidige locatie te zien."
    exit 1
fi