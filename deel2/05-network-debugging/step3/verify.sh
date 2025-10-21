#!/bin/bash

# Controleer of de gebruiker pod-to-service connectivity heeft getest

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Controleer of debug-pod en client-pod bestaan
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
client_pod_status=$(kubectl get pod client-pod -n network --no-headers 2>/dev/null | awk '{print $3}')

if [ "$debug_pod_status" != "Running" ]; then
    echo "Debug pod is niet running. Status: $debug_pod_status"
    exit 1
fi

if [ "$client_pod_status" != "Running" ]; then
    echo "Client pod is niet running. Status: $client_pod_status"
    exit 1
fi

# Test DNS resolution
if ! kubectl exec debug-pod -n network -- nslookup frontend-service.network.svc.cluster.local &> /dev/null; then
    echo "DNS resolution voor frontend-service faalt."
    exit 1
fi

# Test basic HTTP connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://frontend-service.network.svc.cluster.local &> /dev/null; then
    echo "HTTP connectivity naar frontend-service faalt."
    exit 1
fi

# Test backend service connectivity op juiste port
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://backend-service.network.svc.cluster.local:8080 &> /dev/null; then
    echo "Connectivity naar backend-service op port 8080 faalt."
    exit 1
fi

# Test database port connectivity
if ! kubectl exec debug-pod -n network -- nc -zv database-service.network.svc.cluster.local 5432 &> /dev/null; then
    echo "Database port connectivity faalt."
    exit 1
fi

# Test client pod connectivity
if ! kubectl exec client-pod -n network -- curl -s --connect-timeout 5 http://frontend-service.network.svc.cluster.local &> /dev/null; then
    echo "Client pod connectivity naar frontend-service faalt."
    exit 1
fi

# Test cross-namespace connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://kubernetes.default.svc.cluster.local &> /dev/null; then
    echo "Cross-namespace connectivity faalt."
    exit 1
fi

# Controleer of services de juiste endpoints hebben
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

# Test direct pod IP connectivity
frontend_pod_ip=$(kubectl get pods -n network -l app=frontend -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
if [ -n "$frontend_pod_ip" ]; then
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$frontend_pod_ip:80 &> /dev/null; then
        echo "Direct pod IP connectivity faalt."
        exit 1
    fi
else
    echo "Kon frontend pod IP niet ophalen."
    exit 1
fi

# Test of broken-service nu werkt (na reparatie in vorige stap)
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://broken-service.network.svc.cluster.local &> /dev/null; then
    echo "Broken service connectivity faalt nog steeds."
    exit 1
fi

# Test failing-readiness service (zou moeten falen of geen endpoints hebben)
failing_endpoints=$(kubectl get endpoints failing-readiness-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ "$failing_endpoints" != "<none>" ] && [ -n "$failing_endpoints" ]; then
    # Als er endpoints zijn, test connectivity
    kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://failing-readiness-service.network.svc.cluster.local &> /dev/null
    # Dit kan falen, wat verwacht is
fi

# Test service discovery via environment variables
env_services=$(kubectl exec debug-pod -n network -- env 2>/dev/null | grep -c "_SERVICE_" || true)
if [ "$env_services" -eq 0 ]; then
    echo "Geen service environment variables gevonden."
    # Dit is niet kritiek, hangt af van wanneer pod is gestart
fi

# Test load balancing door meerdere requests
success_count=0
for i in {1..3}; do
    if kubectl exec debug-pod -n network -- curl -s --connect-timeout 3 http://frontend-service &> /dev/null; then
        ((success_count++))
    fi
done

if [ "$success_count" -eq 0 ]; then
    echo "Alle load balancing tests faalden."
    exit 1
fi

# Test NodePort connectivity (intern)
node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}' 2>/dev/null)
if [ -n "$node_ip" ]; then
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$node_ip:30080 &> /dev/null; then
        echo "NodePort connectivity faalt."
        # Dit is niet kritiek, NodePort kan externe toegang vereisen
    fi
fi

# Test of pods network interfaces hebben
if ! kubectl exec debug-pod -n network -- ip addr show eth0 &> /dev/null; then
    echo "Pod network interface niet gevonden."
    exit 1
fi

echo "Fantastisch! Je hebt pod-to-service connectivity getest en begrijpt hoe network communication werkt in Kubernetes."
exit 0