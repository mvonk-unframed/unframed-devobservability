#!/bin/bash

# Verificatie voor stap 3: cd navigatie
# Controleer of de gebruiker naar projects/web is genavigeerd

# Check huidige directory
current_dir=$(pwd)

if [[ "$current_dir" == *"/projects/web" ]]; then
    echo "✅ Uitstekend! Je bent succesvol naar de projects/web directory genavigeerd."
    echo "📍 Je huidige locatie is: $current_dir"
    exit 0
elif [[ "$current_dir" == *"/projects" ]]; then
    echo "⚠️  Je bent in de projects directory, maar nog niet in de web subdirectory."
    echo "💡 Tip: Gebruik 'cd web' om naar de web subdirectory te gaan."
    exit 1
elif history | grep -q "cd.*projects"; then
    echo "⚠️  Je hebt geprobeerd naar projects te navigeren, maar je bent er niet."
    echo "💡 Tip: Controleer je huidige locatie met 'pwd' en probeer 'cd projects/web'."
    exit 1
else
    echo "❌ Het lijkt erop dat je nog niet naar projects/web bent genavigeerd."
    echo "💡 Tip: Gebruik 'cd projects/web' om naar de juiste directory te gaan."
    exit 1
fi