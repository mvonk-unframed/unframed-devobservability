#!/bin/bash

# Verificatie voor stap 4: Scripts executable maken
# Controleer of de gebruiker de scripts uitvoerbaar heeft gemaakt

errors=0

# Check of chmod commando's zijn uitgevoerd
if ! history | grep -q "chmod.*x\|chmod.*755"; then
    echo "❌ Het lijkt erop dat je nog geen chmod commando's hebt uitgevoerd om scripts executable te maken."
    echo "💡 Tip: Gebruik chmod u+x of chmod 755 voor scripts."
    exit 1
fi

echo "Controleren van script rechten..."

# Check backup.sh (moet uitvoerbaar zijn)
if [ -f "/home/student/scripts/backup.sh" ]; then
    if [ -x "/home/student/scripts/backup.sh" ]; then
        echo "✅ backup.sh is uitvoerbaar"
    else
        echo "❌ backup.sh is niet uitvoerbaar"
        errors=$((errors + 1))
    fi
else
    echo "❌ backup.sh bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check monitor.sh (moet uitvoerbaar zijn)
if [ -f "/home/student/scripts/monitor.sh" ]; then
    if [ -x "/home/student/scripts/monitor.sh" ]; then
        echo "✅ monitor.sh is uitvoerbaar"
    else
        echo "❌ monitor.sh is niet uitvoerbaar"
        errors=$((errors + 1))
    fi
else
    echo "❌ monitor.sh bestand niet gevonden"
    errors=$((errors + 1))
fi

# Check process_data.py (moet uitvoerbaar zijn)
if [ -f "/home/student/scripts/process_data.py" ]; then
    if [ -x "/home/student/scripts/process_data.py" ]; then
        echo "✅ process_data.py is uitvoerbaar"
    else
        echo "❌ process_data.py is niet uitvoerbaar"
        errors=$((errors + 1))
    fi
else
    echo "❌ process_data.py bestand niet gevonden"
    errors=$((errors + 1))
fi

# Test of scripts daadwerkelijk kunnen worden uitgevoerd
echo ""
echo "Testen van script uitvoering..."

# Test backup.sh
if [ -x "/home/student/scripts/backup.sh" ]; then
    if timeout 5 /home/student/scripts/backup.sh >/dev/null 2>&1; then
        echo "✅ backup.sh kan succesvol worden uitgevoerd"
    else
        echo "⚠️  backup.sh is uitvoerbaar maar heeft mogelijk een runtime fout"
    fi
fi

# Test monitor.sh
if [ -x "/home/student/scripts/monitor.sh" ]; then
    if timeout 5 /home/student/scripts/monitor.sh >/dev/null 2>&1; then
        echo "✅ monitor.sh kan succesvol worden uitgevoerd"
    else
        echo "⚠️  monitor.sh is uitvoerbaar maar heeft mogelijk een runtime fout"
    fi
fi

# Test process_data.py
if [ -x "/home/student/scripts/process_data.py" ]; then
    if timeout 5 /home/student/scripts/process_data.py >/dev/null 2>&1; then
        echo "✅ process_data.py kan succesvol worden uitgevoerd"
    else
        echo "⚠️  process_data.py is uitvoerbaar maar heeft mogelijk een runtime fout"
    fi
fi

if [ $errors -eq 0 ]; then
    echo ""
    echo "✅ Uitstekend! Je hebt alle scripts executable gemaakt."
    echo "💡 Je hebt geleerd:"
    echo "   - Scripts executable maken met chmod u+x"
    echo "   - Numerieke chmod gebruiken (755)"
    echo "   - Wildcards gebruiken (*.sh, *.py)"
    echo "   - Het belang van execute rechten voor scripts"
    exit 0
else
    echo ""
    echo "❌ Er zijn nog $errors fouten. Zorg dat alle scripts uitvoerbaar zijn."
    echo "💡 Tip: Gebruik 'chmod u+x script.sh' of 'chmod 755 script.sh'"
    echo "💡 Controleer met 'ls -l /home/student/scripts/'"
    exit 1
fi
