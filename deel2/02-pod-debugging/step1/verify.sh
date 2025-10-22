#!/bin/bash

# Controleer of de gebruiker de pod status analyse opdracht correct heeft uitgevoerd

# Controleer of pod-status-analysis ConfigMap bestaat
if ! kubectl get configmap pod-status-analysis -n default &> /dev/null; then
    echo "❌ ConfigMap 'pod-status-analysis' niet gevonden in default namespace."
    echo "💡 Tip: Maak een ConfigMap aan met pod status tellingen uit debugging namespace"
    exit 1
fi

# Controleer of ready-analysis Secret bestaat
if ! kubectl get secret ready-analysis -n default &> /dev/null; then
    echo "❌ Secret 'ready-analysis' niet gevonden in default namespace."
    echo "💡 Tip: Maak een Secret aan met informatie over een not-ready pod"
    exit 1
fi

# Haal werkelijke waarden op
actual_running=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "Running" || echo "0")
actual_crashloop=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "CrashLoopBackOff" || echo "0")
actual_imagepull=$(kubectl get pods -n debugging --no-headers 2>/dev/null | grep -c "ImagePullBackOff" || echo "0")

# Haal waarden uit ConfigMap op
config_running=$(kubectl get configmap pod-status-analysis -n default -o jsonpath='{.data.running-pods}' 2>/dev/null)
config_crashloop=$(kubectl get configmap pod-status-analysis -n default -o jsonpath='{.data.crashloop-pods}' 2>/dev/null)
config_imagepull=$(kubectl get configmap pod-status-analysis -n default -o jsonpath='{.data.imagepull-pods}' 2>/dev/null)

# Valideer tellingen
if [ "$config_running" != "$actual_running" ]; then
    echo "❌ Running pods telling incorrect. Verwacht: $actual_running, Gevonden: $config_running"
    exit 1
fi

if [ "$config_crashloop" != "$actual_crashloop" ]; then
    echo "❌ CrashLoopBackOff pods telling incorrect. Verwacht: $actual_crashloop, Gevonden: $config_crashloop"
    exit 1
fi

if [ "$config_imagepull" != "$actual_imagepull" ]; then
    echo "❌ ImagePullBackOff pods telling incorrect. Verwacht: $actual_imagepull, Gevonden: $config_imagepull"
    exit 1
fi

# Controleer ready-analysis Secret
pod_name=$(kubectl get secret ready-analysis -n default -o jsonpath='{.data.pod-name}' 2>/dev/null | base64 -d)
reason=$(kubectl get secret ready-analysis -n default -o jsonpath='{.data.reason}' 2>/dev/null | base64 -d)

if [ -z "$pod_name" ] || [ -z "$reason" ]; then
    echo "❌ Secret 'ready-analysis' mist vereiste data (pod-name en reason)."
    exit 1
fi

echo "✅ Uitstekend! Je hebt pod status analyse beheerst:"
echo "   - Running pods: $actual_running"
echo "   - CrashLoopBackOff pods: $actual_crashloop"
echo "   - ImagePullBackOff pods: $actual_imagepull"
echo "   - Identified not-ready pod: $pod_name (reason: $reason)"
echo "✅ Je begrijpt nu pod lifecycle states en het verschil tussen READY en STATUS!"
exit 0