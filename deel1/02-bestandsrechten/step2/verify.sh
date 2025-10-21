#!/bin/bash

# Verificatie voor stap 2: chmod commando's
# Controleer of de gebruiker de juiste chmod commando's heeft uitgevoerd

errors=0

# Check of chmod commando's zijn uitgevoerd
if ! history | grep -q "chmod"; then
    echo "❌ Het lijkt erop dat je nog geen chmod commando's hebt uitgevoerd."
    echo "💡 Tip: Gebruik de chmod commando's uit de instructies."
    exit 1
fi

echo "Controleren van bestandsrechten..."

# Check secrets.conf (moet 600 zijn)
if [ -f "/home/student/config/secrets.conf" ]; then
    perms=$(stat -c "%a" /home/student/config/secrets.conf 2>/dev/null)
    if [ "$perms" = "600" ]; then
        echo "✅ secrets.conf heeft de juiste rechten (600)"
    else
        echo "❌ secrets.conf heeft verkeerde rechten ($perms), moet 600 zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ secrets.conf bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check readme.txt (moet 644 zijn)
if [ -f "/home/student/documents/readme.txt" ]; then
    perms=$(stat -c "%a" /home/student/documents/readme.txt 2>/dev/null)
    if [ "$perms" = "644" ]; then
        echo "✅ readme.txt heeft de juiste rechten (644)"
    else
        echo "❌ readme.txt heeft verkeerde rechten ($perms), moet 644 zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ readme.txt bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check project_notes.txt (moet groep write hebben, others niet)
if [ -f "/home/student/shared/project_notes.txt" ]; then
    perms=$(stat -c "%a" /home/student/shared/project_notes.txt 2>/dev/null)
    # Accepteer 664 (rw-rw-r--) of 660 (rw-rw----)
    if [ "$perms" = "664" ] || [ "$perms" = "660" ]; then
        echo "✅ project_notes.txt heeft de juiste rechten ($perms)"
    else
        echo "❌ project_notes.txt heeft verkeerde rechten ($perms), moet 664 of 660 zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ project_notes.txt bestand niet gevonden"
    errors=$((errors + 1))
fi

if [ $errors -eq 0 ]; then
    echo ""
    echo "✅ Uitstekend! Je hebt alle chmod commando's correct uitgevoerd."
    echo "💡 Je hebt geleerd:"
    echo "   - Numerieke chmod (600, 644)"
    echo "   - Symbolische chmod (g+w, o-w)"
    echo "   - Beveiligingsprincipes toepassen"
    exit 0
else
    echo ""
    echo "❌ Er zijn nog $errors fouten. Controleer de chmod commando's en probeer opnieuw."
    echo "💡 Tip: Gebruik 'ls -l' om de huidige rechten te controleren."
    exit 1
fi