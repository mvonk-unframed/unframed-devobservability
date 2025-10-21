#!/bin/bash

# Verificatie voor stap 5: Finale verificatie van alle rechten
# Controleer of alle bestandsrechten correct zijn ingesteld

errors=0
warnings=0

echo "=== FINALE VERIFICATIE VAN BESTANDSRECHTEN ==="
echo ""

# Check scripts directory
echo "Controleren van scripts..."
for script in backup.sh monitor.sh process_data.py; do
    if [ -f "/home/student/scripts/$script" ]; then
        if [ -x "/home/student/scripts/$script" ]; then
            perms=$(stat -c "%a" "/home/student/scripts/$script" 2>/dev/null)
            if [ "$perms" = "755" ] || [ "$perms" = "754" ] || [ "$perms" = "750" ]; then
                echo "✅ $script: uitvoerbaar met goede rechten ($perms)"
            else
                echo "⚠️  $script: uitvoerbaar maar ongebruikelijke rechten ($perms)"
                warnings=$((warnings + 1))
            fi
        else
            echo "❌ $script: niet uitvoerbaar"
            errors=$((errors + 1))
        fi
    else
        echo "❌ $script: bestand niet gevonden"
        errors=$((errors + 1))
    fi
done

echo ""
echo "Controleren van configuratie bestanden..."

# Check secrets.conf (moet 600 zijn)
if [ -f "/home/student/config/secrets.conf" ]; then
    perms=$(stat -c "%a" /home/student/config/secrets.conf 2>/dev/null)
    if [ "$perms" = "600" ]; then
        echo "✅ secrets.conf: correct beveiligd (600)"
    else
        echo "❌ secrets.conf: onveilige rechten ($perms), moet 600 zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ secrets.conf: bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check readme.txt (moet 644 zijn)
if [ -f "/home/student/documents/readme.txt" ]; then
    perms=$(stat -c "%a" /home/student/documents/readme.txt 2>/dev/null)
    if [ "$perms" = "644" ]; then
        echo "✅ readme.txt: correct toegankelijk (644)"
    else
        echo "❌ readme.txt: verkeerde rechten ($perms), moet 644 zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ readme.txt: bestand niet gevonden"
    errors=$((errors + 1))
fi

echo ""
echo "Controleren van eigendom..."

# Check config.bak eigendom
if [ -f "/home/student/backup/config.bak" ]; then
    owner=$(stat -c "%U" /home/student/backup/config.bak 2>/dev/null)
    group=$(stat -c "%G" /home/student/backup/config.bak 2>/dev/null)
    if [ "$owner" = "student" ]; then
        echo "✅ config.bak: juiste eigenaar (student)"
    else
        echo "❌ config.bak: verkeerde eigenaar ($owner), moet student zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ config.bak: bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check project_notes.txt groep
if [ -f "/home/student/shared/project_notes.txt" ]; then
    group=$(stat -c "%G" /home/student/shared/project_notes.txt 2>/dev/null)
    if [ "$group" = "projectteam" ]; then
        echo "✅ project_notes.txt: juiste groep (projectteam)"
    else
        echo "❌ project_notes.txt: verkeerde groep ($group), moet projectteam zijn"
        errors=$((errors + 1))
    fi
else
    echo "❌ project_notes.txt: bestand niet gevonden"
    errors=$((errors + 1))
fi

echo ""
echo "Controleren van groepen..."

# Check of projectteam groep bestaat
if getent group projectteam >/dev/null 2>&1; then
    echo "✅ projectteam groep bestaat"
else
    echo "❌ projectteam groep bestaat niet"
    errors=$((errors + 1))
fi

# Test script uitvoering
echo ""
echo "Testen van script functionaliteit..."

for script in backup.sh monitor.sh process_data.py; do
    if [ -x "/home/student/scripts/$script" ]; then
        if timeout 3 /home/student/scripts/$script >/dev/null 2>&1; then
            echo "✅ $script: kan succesvol worden uitgevoerd"
        else
            echo "⚠️  $script: uitvoerbaar maar mogelijk runtime issues"
            warnings=$((warnings + 1))
        fi
    fi
done

echo ""
echo "=== SAMENVATTING ==="

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo "🎉 PERFECT! Alle bestandsrechten zijn correct ingesteld!"
    echo ""
    echo "✅ Je hebt succesvol geleerd:"
    echo "   • Bestandsrechten lezen en interpreteren"
    echo "   • Chmod gebruiken (numeriek en symbolisch)"
    echo "   • Eigendom wijzigen met chown"
    echo "   • Scripts executable maken"
    echo "   • Beveiligingsprincipes toepassen"
    echo "   • Groepen aanmaken en beheren"
    echo ""
    echo "Je bent nu klaar voor geavanceerdere Linux systeembeheer!"
    exit 0
elif [ $errors -eq 0 ]; then
    echo "✅ Goed gedaan! Alle kritieke rechten zijn correct."
    echo "⚠️  Er zijn $warnings waarschuwingen, maar deze zijn niet kritiek."
    echo ""
    echo "Je hebt de bestandsrechten oefening succesvol afgerond!"
    exit 0
else
    echo "❌ Er zijn nog $errors fouten die opgelost moeten worden."
    if [ $warnings -gt 0 ]; then
        echo "⚠️  En $warnings waarschuwingen."
    fi
    echo ""
    echo "💡 Controleer de fouten hierboven en probeer opnieuw."
    echo "💡 Gebruik 'ls -l' om de huidige rechten te bekijken."
    exit 1
fi
