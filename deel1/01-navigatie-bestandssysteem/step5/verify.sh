#!/bin/bash

# Verificatie voor stap 5: du -sh commando
# Controleer of de gebruiker het du -sh commando heeft uitgevoerd

# Check of du -sh in de command history staat
if history | grep -q "du -sh"; then
    echo "✅ Uitstekend! Je hebt du -sh gebruikt om directory groottes te controleren."
    echo "📏 Je hebt nu geleerd hoe je schijfgebruik per directory kunt analyseren."
    echo "🎯 Je hebt alle navigatie en bestandssysteem basics onder de knie!"
    exit 0
elif history | grep -q "du"; then
    echo "✅ Goed! Je hebt du gebruikt."
    echo "💡 Tip: Gebruik du -sh voor een overzichtelijke summary in human-readable formaat."
    exit 0
else
    echo "❌ Het lijkt erop dat je het du commando nog niet hebt uitgevoerd."
    echo "💡 Tip: Typ 'du -sh *' om de grootte van alle directories te zien."
    exit 1
fi
