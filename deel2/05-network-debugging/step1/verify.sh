#!/bin/bash

# Controleer of de gebruiker service discovery heeft verkend

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Controleer of er services zijn in network namespace
service_count=$(kubectl get services -n network --no-headers 2>/dev/null | wc -l)
if [ "$service_count" -eq 0 ]; then
    echo "Geen services gevonden in network namespace."
    exit 1
fi

# Test of debug-pod bestaat en running is
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" != "Running" ]; then
    echo "Debug pod is niet running. Status: $debug_pod_status"
    # Niet kritiek, maar waarschuwing
fi

# Controleer of frontend-service bestaat
if ! kubectl get service frontend-service -n network &> /dev/null; then
    echo "Frontend service niet gevonden."
    exit 1
fi

# Controleer of frontend-service endpoints heeft
frontend_endpoints=$(kubectl get endpoints frontend-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ -z "$frontend_endpoints" ] || [ "$frontend_endpoints" = "<none>" ]; then
    echo "Frontend service heeft geen endpoints."
    exit 1
fi

# Controleer of broken-service geen endpoints heeft (dit is verwacht)
broken_endpoints=$(kubectl get endpoints broken-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ "$broken_endpoints" != "<none>" ] && [ -n "$broken_endpoints" ]; then
    echo "Broken service zou geen endpoints moeten hebben."
    exit 1
fi

# Test DNS resolution (als debug pod running is)
if [ "$debug_pod_status" = "Running" ]; then
    if ! kubectl exec debug-pod -n network -- nslookup frontend-service.network.svc.cluster.local &> /dev/null; then
        echo "DNS resolution voor frontend-service faalt."
        exit 1
    fi
    
    # Test korte DNS naam
    if ! kubectl exec debug-pod -n network -- nslookup frontend-service &> /dev/null; then
        echo "Korte DNS naam resolution faalt."
        exit 1
    fi
fi

# Controleer of NodePort service bestaat
if ! kubectl get service frontend-nodeport -n network &> /dev/null; then
    echo "Frontend NodePort service niet gevonden."
    exit 1
fi

# Controleer NodePort service type
nodeport_type=$(kubectl get service frontend-nodeport -n network -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$nodeport_type" != "NodePort" ]; then
    echo "Frontend service is niet van type NodePort."
    exit 1
fi

# Controleer of er verschillende service types zijn
clusterip_count=$(kubectl get services -n network -o jsonpath='{.items[?(@.spec.type=="ClusterIP")].metadata.name}' 2>/dev/null | wc -w)
nodeport_count=$(kubectl get services -n network -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' 2>/dev/null | wc -w)

if [ "$clusterip_count" -eq 0 ]; then
    echo "Geen ClusterIP services gevonden."
    exit 1
fi

if [ "$nodeport_count" -eq 0 ]; then
    echo "Geen NodePort services gevonden."
    exit 1
fi

# Controleer of pods de juiste labels hebben
frontend_pods=$(kubectl get pods -n network -l app=frontend --no-headers 2>/dev/null | wc -l)
if [ "$frontend_pods" -eq 0 ]; then
    echo "Geen frontend pods met juiste labels gevonden."
    exit 1
fi

# Controleer of broken-app pods bestaan maar service selector verkeerd is
broken_pods=$(kubectl get pods -n network -l app=broken-app --no-headers 2>/dev/null | wc -l)
if [ "$broken_pods" -eq 0 ]; then
    echo "Geen broken-app pods gevonden."
    exit 1
fi

# Controleer broken service selector
broken_selector=$(kubectl get service broken-service -n network -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$broken_selector" = "broken-app" ]; then
    echo "Broken service selector is correct - dit zou verkeerd moeten zijn voor de oefening."
    exit 1
fi

echo "Uitstekend! Je hebt service discovery verkend en begrijpt hoe services, endpoints en DNS resolution werken in Kubernetes."
exit 0