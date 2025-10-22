#!/bin/bash

# Controleer of de gebruiker de context management opdracht correct heeft uitgevoerd

# Controleer of context-test-pod bestaat in monitoring namespace
if ! kubectl get pod context-test-pod -n monitoring &> /dev/null; then
    echo "❌ Pod 'context-test-pod' niet gevonden in monitoring namespace."
    echo "💡 Tip: Zorg dat je de monitoring namespace als default hebt ingesteld voordat je de pod aanmaakt"
    exit 1
fi

# Controleer of context-demo ConfigMap bestaat in development namespace
if ! kubectl get configmap context-demo -n development &> /dev/null; then
    echo "❌ ConfigMap 'context-demo' niet gevonden in development namespace."
    echo "💡 Tip: Zorg dat je de development namespace als default hebt ingesteld voordat je de ConfigMap aanmaakt"
    exit 1
fi

# Controleer of de huidige default namespace development is
current_namespace=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
if [ "$current_namespace" != "development" ]; then
    echo "❌ Huidige default namespace is '$current_namespace', verwacht 'development'."
    echo "💡 Tip: Gebruik 'kubectl config set-context --current --namespace=development'"
    exit 1
fi

# Controleer ConfigMap inhoud
config_message=$(kubectl get configmap context-demo -n development -o jsonpath='{.data.message}' 2>/dev/null)
if [ -z "$config_message" ]; then
    echo "❌ ConfigMap 'context-demo' mist de 'message' key."
    exit 1
fi

echo "✅ Uitstekend! Je hebt succesvol context management gedemonstreerd:"
echo "   - Pod 'context-test-pod' aangemaakt in monitoring namespace"
echo "   - ConfigMap 'context-demo' aangemaakt in development namespace"
echo "   - Default namespace ingesteld op: $current_namespace"
echo "✅ Je begrijpt nu hoe default namespaces werken en hoe je efficiënter kunt werken!"
exit 0