#!/bin/bash

# Controleer of de gebruiker service endpoints debugging heeft uitgevoerd

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Test of gebruiker endpoints kan bekijken
if ! kubectl get endpoints -n network &> /dev/null; then
    echo "Kon endpoints niet bekijken."
    exit 1
fi

# Controleer of frontend-service endpoints heeft
frontend_endpoints=$(kubectl get endpoints frontend-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ -z "$frontend_endpoints" ] || [ "$frontend_endpoints" = "<none>" ]; then
    echo "Frontend service heeft geen endpoints."
    exit 1
fi

# Controleer of broken-service oorspronkelijk geen endpoints had
# (We testen dit door te kijken of de service bestaat)
if ! kubectl get service broken-service -n network &> /dev/null; then
    echo "Broken service niet gevonden."
    exit 1
fi

# Test of failing-readiness service bestaat
if ! kubectl get service failing-readiness-service -n network &> /dev/null; then
    echo "Failing-readiness service niet gevonden."
    exit 1
fi

# Controleer of failing-readiness pods bestaan maar mogelijk niet ready zijn
failing_pods=$(kubectl get pods -n network -l app=failing-readiness --no-headers 2>/dev/null | wc -l)
if [ "$failing_pods" -eq 0 ]; then
    echo "Geen failing-readiness pods gevonden."
    exit 1
fi

# Test of manual-service is aangemaakt
if ! kubectl get service manual-service -n network &> /dev/null; then
    echo "Manual service niet aangemaakt."
    exit 1
fi

# Test of manual endpoints bestaan
if ! kubectl get endpoints manual-service -n network &> /dev/null; then
    echo "Manual endpoints niet gevonden."
    exit 1
fi

# Controleer of broken-service is gerepareerd (zou nu endpoints moeten hebben)
broken_endpoints_after=$(kubectl get endpoints broken-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ "$broken_endpoints_after" = "<none>" ] || [ -z "$broken_endpoints_after" ]; then
    echo "Broken service is niet gerepareerd - heeft nog steeds geen endpoints."
    exit 1
fi

# Test of de service selector is gecorrigeerd
broken_selector=$(kubectl get service broken-service -n network -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$broken_selector" != "broken-app" ]; then
    echo "Broken service selector is niet gecorrigeerd."
    exit 1
fi

# Test connectivity naar gerepareerde service (als debug pod running is)
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" = "Running" ]; then
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://broken-service.network.svc.cluster.local &> /dev/null; then
        echo "Connectivity naar gerepareerde broken-service faalt."
        exit 1
    fi
fi

# Controleer of database service endpoints heeft
database_endpoints=$(kubectl get endpoints database-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ -z "$database_endpoints" ] || [ "$database_endpoints" = "<none>" ]; then
    echo "Database service heeft geen endpoints."
    exit 1
fi

# Test of backend service correct port mapping heeft
backend_service_port=$(kubectl get service backend-service -n network -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$backend_service_port" != "8080" ]; then
    echo "Backend service heeft niet de verwachte port 8080."
    exit 1
fi

# Controleer of er events zijn voor endpoints
events_count=$(kubectl get events -n network --field-selector involvedObject.kind=Endpoints --no-headers 2>/dev/null | wc -l)
if [ "$events_count" -eq 0 ]; then
    echo "Geen endpoint events gevonden."
    # Dit is niet kritiek, events kunnen verlopen zijn
fi

# Test of pods de juiste labels hebben voor service matching
frontend_pods_with_labels=$(kubectl get pods -n network -l app=frontend --no-headers 2>/dev/null | wc -l)
if [ "$frontend_pods_with_labels" -eq 0 ]; then
    echo "Geen frontend pods met juiste labels gevonden."
    exit 1
fi

# Controleer of broken-app pods bestaan en nu matched worden door service
broken_app_pods=$(kubectl get pods -n network -l app=broken-app --no-headers 2>/dev/null | wc -l)
if [ "$broken_app_pods" -eq 0 ]; then
    echo "Geen broken-app pods gevonden."
    exit 1
fi

echo "Excellent! Je hebt service endpoints debugging beheerst en een broken service succesvol gerepareerd."
exit 0