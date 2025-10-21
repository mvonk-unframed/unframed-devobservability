#!/bin/bash

# Verificatie voor stap 3: chown commando's
# Controleer of de gebruiker de juiste chown commando's heeft uitgevoerd

errors=0

# Check of chown commando's zijn uitgevoerd
if ! history | grep -q "chown"; then
    echo "❌ Het lijkt erop dat je nog geen chown commando's hebt uitgevoerd."
    echo "💡 Tip: Gebruik de chown commando's uit de instructies."
    exit 1
fi

echo "Controleren van bestandseigendom..."

# Check config.bak eigendom (moet student:student zijn)
if [ -f "/home/student/backup/config.bak" ]; then
    owner=$(stat -c "%U" /home/student/backup/config.bak 2>/dev/null)
    group=$(stat -c "%G" /home/student/backup/config.bak 2>/dev/null)
    if [ "$owner" = "student" ] && [ "$group" = "student" ]; then
        echo "✅ config.bak heeft de juiste eigenaar (student:student)"
    else
        echo "❌ config.bak heeft verkeerde eigenaar ($owner:$group), moet student:student zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ config.bak bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check project_notes.txt groep (moet projectteam zijn)
if [ -f "/home/student/shared/project_notes.txt" ]; then
    group=$(stat -c "%G" /home/student/shared/project_notes.txt 2>/dev/null)
    if [ "$group" = "projectteam" ]; then
        echo "✅ project_notes.txt heeft de juiste groep (projectteam)"
    else
        echo "❌ project_notes.txt heeft verkeerde groep ($group), moet projectteam zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ project_notes.txt bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check documents directory eigendom (moet student:student zijn)
if [ -d "/home/student/documents" ]; then
    owner=$(stat -c "%U" /home/student/documents 2>/dev/null)
    group=$(stat -c "%G" /home/student/documents 2>/dev/null)
    if [ "$owner" = "student" ] && [ "$group" = "student" ]; then
        echo "✅ documents directory heeft de juiste eigenaar (student:student)"
    else
        echo "❌ documents directory heeft verkeerde eigenaar ($owner:$group), moet student:student zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ documents directory niet gevonden"
    errors=$((errors + 1))
fi

# Check of projectteam groep bestaat
if getent group projectteam >/dev/null 2>&1; then
    echo "✅ projectteam groep is aangemaakt"
else
    echo "❌ projectteam groep bestaat niet"
    errors=$((errors + 1))
fi

if [ $errors -eq 0 ]; then
    echo ""
    echo "✅ Uitstekend! Je hebt alle chown commando's correct uitgevoerd."
    echo "💡 Je hebt geleerd:"
    echo "   - Eigendom wijzigen met chown"
    echo "   - Groepen aanmaken en toewijzen"
    echo "   - Recursief eigendom wijzigen met -R"
    echo "   - Sudo gebruiken voor administratieve taken"
    exit 0
else
    echo ""
    echo "❌ Er zijn nog $errors fouten. Controleer de chown commando's en probeer opnieuw."
    echo "💡 Tip: Gebruik 'ls -l' om de huidige eigendom te controleren."
    exit 1
fi
