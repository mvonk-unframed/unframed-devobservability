#!/bin/bash

# Controleer of de gebruiker pod analyse heeft uitgevoerd

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Test of gebruiker pods kan bekijken
if ! kubectl get pods -n network &> /dev/null; then
    echo "Kon pods niet bekijken."
    exit 1
fi

# Controleer pod status
frontend_pods_running=$(kubectl get pods -n network -l app=frontend --no-headers 2>/dev/null | grep "Running" | wc -l)
if [ "$frontend_pods_running" -eq 0 ]; then
    echo "Geen frontend pods running."
    exit 1
fi

backend_pods_running=$(kubectl get pods -n network -l app=backend --no-headers 2>/dev/null | grep "Running" | wc -l)
if [ "$backend_pods_running" -eq 0 ]; then
    echo "Geen backend pods running."
    exit 1
fi

# Controleer pod readiness
frontend_pods_ready=$(kubectl get pods -n network -l app=frontend --no-headers 2>/dev/null | grep "1/1" | wc -l)
if [ "$frontend_pods_ready" -eq 0 ]; then
    echo "Geen frontend pods ready."
    exit 1
fi

backend_pods_ready=$(kubectl get pods -n network -l app=backend --no-headers 2>/dev/null | grep "1/1" | wc -l)
if [ "$backend_pods_ready" -eq 0 ]; then
    echo "Geen backend pods ready."
    exit 1
fi

# Controleer failing-readiness pods (zouden niet ready moeten zijn)
failing_pods_not_ready=$(kubectl get pods -n network -l app=failing-readiness --no-headers 2>/dev/null | grep "0/1" | wc -l)
if [ "$failing_pods_not_ready" -eq 0 ]; then
    echo "Failing-readiness pods zijn ready - dit zou niet moeten (tenzij al gerepareerd)."
    # Niet kritiek, kan al gerepareerd zijn
fi

# Test readiness probe configuratie
failing_readiness_probe=$(kubectl get pods -n network -l app=failing-readiness -o jsonpath='{.items[0].spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [ "$failing_readiness_probe" = "/" ]; then
    echo "Failing-readiness probe is al gerepareerd naar '/'."
    # Dit is goed, betekent dat reparatie is toegepast
fi

# Test pod IP connectiviteit
frontend_pod_ip=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
if [ -z "$frontend_pod_ip" ]; then
    echo "Kon frontend pod IP niet ophalen."
    exit 1
fi

backend_pod_ip=$(kubectl get pods -n network -l app=backend -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
if [ -z "$backend_pod_ip" ]; then
    echo "Kon backend pod IP niet ophalen."
    exit 1
fi

# Test pod logs (moeten beschikbaar zijn)
if ! kubectl logs $(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].metadata.name}') -n network --tail=1 &> /dev/null; then
    echo "Kon frontend pod logs niet ophalen."
    exit 1
fi

# Test pod events
pod_events=$(kubectl get events -n network --field-selector involvedObject.kind=Pod --no-headers 2>/dev/null | wc -l)
if [ "$pod_events" -eq 0 ]; then
    echo "Geen pod events gevonden."
    # Niet kritiek, events kunnen verlopen zijn
fi

# Controleer of failing-readiness deployment is gerepareerd
if kubectl get deployment failing-readiness -n network &> /dev/null; then
    deployment_ready=$(kubectl get deployment failing-readiness -n network --no-headers 2>/dev/null | awk '{print $2}' | grep "1/1" | wc -l)
    if [ "$deployment_ready" -eq 1 ]; then
        echo "Failing-readiness deployment is succesvol gerepareerd."
    fi
fi

# Controleer of pod-analysis secret is aangemaakt
if ! kubectl get secret pod-analysis -n network &> /dev/null; then
    echo "Pod-analysis secret niet aangemaakt."
    exit 1
fi

# Test directe pod connectiviteit (als debug pod running is)
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" = "Running" ]; then
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$frontend_pod_ip &> /dev/null; then
        echo "Directe pod connectiviteit naar frontend faalt."
        exit 1
    fi
    
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$backend_pod_ip &> /dev/null; then
        echo "Directe pod connectiviteit naar backend faalt."
        exit 1
    fi
fi

# Controleer pod restart count (zou laag moeten zijn)
frontend_restarts=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null)
if [ "$frontend_restarts" -gt 5 ]; then
    echo "Frontend pod heeft te veel restarts: $frontend_restarts"
    # Niet kritiek, maar waarschuwing
fi

echo "Uitstekend! Je hebt pod analyse uitgevoerd en begrijpt pod status en readiness in Kubernetes."
exit 0