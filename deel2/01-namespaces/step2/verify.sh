#!/bin/bash

# Controleer of de gebruiker de opdrachten correct heeft uitgevoerd
# 1. Labels toegevoegd aan namespaces
# 2. ConfigMap aangemaakt met namespace analyse

# Controleer of labels zijn toegevoegd aan webapp namespace
webapp_label=$(kubectl get namespace webapp -o jsonpath='{.metadata.labels.purpose}' 2>/dev/null)
if [ "$webapp_label" != "frontend" ]; then
    echo "❌ Label 'purpose=frontend' niet gevonden op webapp namespace."
    echo "💡 Tip: Gebruik 'kubectl label namespace webapp purpose=frontend'"
    exit 1
fi

# Controleer of labels zijn toegevoegd aan database namespace
database_label=$(kubectl get namespace database -o jsonpath='{.metadata.labels.purpose}' 2>/dev/null)
if [ "$database_label" != "backend" ]; then
    echo "❌ Label 'purpose=backend' niet gevonden op database namespace."
    echo "💡 Tip: Gebruik 'kubectl label namespace database purpose=backend'"
    exit 1
fi

# Controleer of ConfigMap bestaat
if ! kubectl get configmap namespace-analysis -n default &> /dev/null; then
    echo "❌ ConfigMap 'namespace-analysis' niet gevonden in default namespace."
    echo "💡 Tip: Maak een ConfigMap aan met namespace statistieken"
    exit 1
fi

# Controleer ConfigMap inhoud
total_ns=$(kubectl get configmap namespace-analysis -n default -o jsonpath='{.data.total-namespaces}' 2>/dev/null)
custom_ns=$(kubectl get configmap namespace-analysis -n default -o jsonpath='{.data.custom-namespaces}' 2>/dev/null)

if [ -z "$total_ns" ] || [ -z "$custom_ns" ]; then
    echo "❌ ConfigMap 'namespace-analysis' mist vereiste data keys."
    echo "💡 Tip: ConfigMap moet 'total-namespaces' en 'custom-namespaces' keys bevatten"
    exit 1
fi

# Valideer of de getallen logisch zijn
actual_total=$(kubectl get namespaces --no-headers | wc -l)
if [ "$total_ns" != "$actual_total" ]; then
    echo "❌ Total namespaces in ConfigMap ($total_ns) komt niet overeen met werkelijk aantal ($actual_total)."
    echo "💡 Tip: Tel opnieuw met 'kubectl get namespaces'"
    exit 1
fi

echo "✅ Uitstekend! Je hebt succesvol:"
echo "   - Labels toegevoegd aan namespaces (webapp: $webapp_label, database: $database_label)"
echo "   - ConfigMap aangemaakt met correcte namespace analyse ($total_ns total, $custom_ns custom)"
echo "   - Namespace metadata management beheerst"
exit 0