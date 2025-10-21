#!/bin/bash

# Verificatie voor stap 4: df -h commando
# Controleer of de gebruiker het df -h commando heeft uitgevoerd

# Check of df -h in de command history staat
if history | grep -q "df -h"; then
    echo "✅ Perfect! Je hebt df -h gebruikt om de schijfruimte te controleren."
    echo "📊 Je hebt nu geleerd hoe je het schijfgebruik kunt monitoren."
    echo "💡 Onthoud: Houd altijd de schijfruimte in de gaten om problemen te voorkomen!"
    exit 0
elif history | grep -q "df"; then
    echo "✅ Goed! Je hebt df gebruikt."
    echo "💡 Tip: Gebruik df -h voor human-readable output (KB, MB, GB)."
    exit 0
else
    echo "❌ Het lijkt erop dat je het df commando nog niet hebt uitgevoerd."
    echo "💡 Tip: Typ 'df -h' om de schijfruimte te controleren."
    exit 1
fi
