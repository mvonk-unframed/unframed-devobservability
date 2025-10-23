#!/bin/bash

# Controleer of de gebruiker service analyse heeft uitgevoerd

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Test of gebruiker services kan bekijken
if ! kubectl get services -n network &> /dev/null; then
    echo "Kon services niet bekijken."
    exit 1
fi

# Test of gebruiker endpoints kan bekijken
if ! kubectl get endpoints -n network &> /dev/null; then
    echo "Kon endpoints niet bekijken."
    exit 1
fi

# Controleer service selectors
frontend_selector=$(kubectl get service frontend-service -n network -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$frontend_selector" != "frontend" ]; then
    echo "Frontend service selector is niet correct."
    exit 1
fi

backend_selector=$(kubectl get service backend-service -n network -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$backend_selector" != "backend" ]; then
    echo "Backend service selector is niet correct."
    exit 1
fi

# Controleer of pods met juiste labels bestaan
frontend_pods=$(kubectl get pods -n network -l app=frontend --no-headers 2>/dev/null | wc -l)
if [ "$frontend_pods" -eq 0 ]; then
    echo "Geen frontend pods met juiste labels gevonden."
    exit 1
fi

backend_pods=$(kubectl get pods -n network -l app=backend --no-headers 2>/dev/null | wc -l)
if [ "$backend_pods" -eq 0 ]; then
    echo "Geen backend pods met juiste labels gevonden."
    exit 1
fi

# Controleer service endpoints
frontend_endpoints=$(kubectl get endpoints frontend-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ -z "$frontend_endpoints" ] || [ "$frontend_endpoints" = "<none>" ]; then
    echo "Frontend service heeft geen endpoints."
    exit 1
fi

backend_endpoints=$(kubectl get endpoints backend-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ -z "$backend_endpoints" ] || [ "$backend_endpoints" = "<none>" ]; then
    echo "Backend service heeft geen endpoints."
    exit 1
fi

# Controleer failing-readiness service (zou geen endpoints moeten hebben)
failing_endpoints=$(kubectl get endpoints failing-readiness-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ "$failing_endpoints" != "<none>" ] && [ -n "$failing_endpoints" ]; then
    echo "Failing-readiness service zou geen endpoints moeten hebben (pods niet ready)."
    # Niet kritiek, kan al gerepareerd zijn
fi

# Controleer poort configuratie
frontend_service_port=$(kubectl get service frontend-service -n network -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$frontend_service_port" != "80" ]; then
    echo "Frontend service port is niet 80."
    exit 1
fi

backend_service_port=$(kubectl get service backend-service -n network -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$backend_service_port" != "8080" ]; then
    echo "Backend service port is niet 8080."
    exit 1
fi

# Test pod poorten
frontend_pod_port=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].spec.containers[0].ports[0].containerPort}' 2>/dev/null)
if [ "$frontend_pod_port" != "80" ]; then
    echo "Frontend pod container port is niet 80."
    exit 1
fi

# Controleer of service-analysis secret is aangemaakt
if ! kubectl get secret service-analysis -n network &> /dev/null; then
    echo "Service-analysis secret niet aangemaakt."
    exit 1
fi

# Test service connectiviteit (als debug pod running is)
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" = "Running" ]; then
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://frontend-service &> /dev/null; then
        echo "Connectivity naar frontend service faalt."
        exit 1
    fi
    
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://backend-service:8080 &> /dev/null; then
        echo "Connectivity naar backend service faalt."
        exit 1
    fi
fi

# Controleer services zonder endpoints
services_without_endpoints=$(kubectl get endpoints -n network | grep "<none>" | wc -l)
if [ "$services_without_endpoints" -eq 0 ]; then
    echo "Alle services hebben endpoints - dit is goed!"
fi

echo "Uitstekend! Je hebt service analyse uitgevoerd en begrijpt hoe services labels gebruiken om pods te selecteren."
exit 0