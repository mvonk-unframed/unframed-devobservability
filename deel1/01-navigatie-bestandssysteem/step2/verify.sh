#!/bin/bash

# Verificatie voor stap 2: ls -lah commando
# Controleer of de gebruiker het ls -lah commando heeft uitgevoerd

# Check of ls -lah in de command history staat
if history | grep -q "ls -lah"; then
    echo "✅ Perfect! Je hebt ls -lah gebruikt om de directory inhoud te bekijken."
    echo "📋 Je hebt nu geleerd hoe je gedetailleerde informatie over bestanden kunt zien."
    exit 0
elif history | grep -q "ls -la"; then
    echo "✅ Goed! Je hebt ls -la gebruikt."
    echo "💡 Tip: Probeer ook ls -lah voor human-readable bestandsgroottes."
    exit 0
elif history | grep -q "ls"; then
    echo "⚠️  Je hebt ls gebruikt, maar probeer ls -lah voor meer details."
    echo "💡 De -lah opties geven je permissions, grootte en verborgen bestanden."
    exit 1
else
    echo "❌ Het lijkt erop dat je het ls commando nog niet hebt uitgevoerd."
    echo "💡 Tip: Typ 'ls -lah' om de directory inhoud gedetailleerd te bekijken."
    exit 1
fi