#!/bin/bash

# Controleer of de gebruiker het complete network troubleshooting scenario heeft doorlopen

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Test of debug-pod running is voor connectivity tests
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" != "Running" ]; then
    echo "Debug pod is niet running voor troubleshooting tests."
    exit 1
fi

# Test complete connectivity flow
ingress_ip=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -z "$ingress_ip" ]; then
    echo "Kon ingress controller IP niet ophalen."
    exit 1
fi

# Test DNS resolution voor alle services
services=("frontend-service" "backend-service" "database-service")
for service in "${services[@]}"; do
    if ! kubectl exec debug-pod -n network -- nslookup $service.network.svc.cluster.local &> /dev/null; then
        echo "DNS resolution faalt voor $service."
        exit 1
    fi
done

# Test ingress connectivity voor alle hosts
hosts=("frontend.local" "api.local")
for host in "${hosts[@]}"; do
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: $host" http://$ingress_ip &> /dev/null; then
        echo "Ingress connectivity faalt voor $host."
        exit 1
    fi
done

# Test service-to-service connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://frontend-service &> /dev/null; then
    echo "Service connectivity naar frontend faalt."
    exit 1
fi

if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://backend-service:8080 &> /dev/null; then
    echo "Service connectivity naar backend faalt."
    exit 1
fi

# Test database port connectivity
if ! kubectl exec debug-pod -n network -- nc -zv database-service 5432 &> /dev/null; then
    echo "Database port connectivity faalt."
    exit 1
fi

# Controleer of failing-readiness deployment is gerepareerd
failing_ready_pods=$(kubectl get pods -n network -l app=failing-readiness --no-headers 2>/dev/null | grep "1/1" | wc -l)
if [ "$failing_ready_pods" -eq 0 ]; then
    echo "Failing-readiness pods zijn nog steeds niet ready na reparatie."
    # Dit is niet kritiek, reparatie kan tijd nodig hebben
fi

# Test of broken-service is gerepareerd
broken_endpoints=$(kubectl get endpoints broken-service -n network --no-headers 2>/dev/null | awk '{print $2}')
if [ "$broken_endpoints" = "<none>" ] || [ -z "$broken_endpoints" ]; then
    echo "Broken service heeft nog steeds geen endpoints."
    exit 1
fi

# Test connectivity naar gerepareerde broken service
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://broken-service &> /dev/null; then
    echo "Connectivity naar gerepareerde broken service faalt."
    exit 1
fi

# Test load balancing door meerdere requests
success_count=0
for i in {1..3}; do
    if kubectl exec debug-pod -n network -- curl -s --connect-timeout 3 http://frontend-service &> /dev/null; then
        ((success_count++))
    fi
done

if [ "$success_count" -eq 0 ]; then
    echo "Load balancing test faalde - geen succesvolle requests."
    exit 1
fi

# Test NodePort service
if ! kubectl get service frontend-nodeport -n network &> /dev/null; then
    echo "NodePort service niet gevonden."
    exit 1
fi

# Test of TLS ingress is aangemaakt (optioneel)
if kubectl get ingress secure-ingress -n network &> /dev/null; then
    if ! kubectl get secret secure-tls -n network &> /dev/null; then
        echo "TLS ingress bestaat maar TLS secret niet."
        exit 1
    fi
fi

# Controleer overall cluster health
total_pods=$(kubectl get pods -n network --no-headers 2>/dev/null | wc -l)
running_pods=$(kubectl get pods -n network --no-headers 2>/dev/null | grep "Running" | wc -l)

if [ "$total_pods" -eq 0 ]; then
    echo "Geen pods gevonden in network namespace."
    exit 1
fi

if [ "$running_pods" -eq 0 ]; then
    echo "Geen running pods gevonden."
    exit 1
fi

# Test events voor troubleshooting
event_count=$(kubectl get events -n network --no-headers 2>/dev/null | wc -l)
if [ "$event_count" -eq 0 ]; then
    echo "Geen events gevonden voor troubleshooting analyse."
    # Dit is niet kritiek, events kunnen verlopen zijn
fi

# Test ingress controller health
controller_running=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | grep "Running" | wc -l)
if [ "$controller_running" -eq 0 ]; then
    echo "Ingress controller is niet running."
    exit 1
fi

# Test complete network flow: ingress → service → pod
# Frontend flow
if ! kubectl exec debug-pod -n network -- curl -s -H "Host: frontend.local" http://$ingress_ip &> /dev/null; then
    echo "Complete frontend network flow faalt."
    exit 1
fi

# API flow
if ! kubectl exec debug-pod -n network -- curl -s -H "Host: api.local" http://$ingress_ip/api &> /dev/null; then
    echo "Complete API network flow faalt."
    exit 1
fi

# Test cross-namespace connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://kubernetes.default.svc.cluster.local &> /dev/null; then
    echo "Cross-namespace connectivity faalt."
    exit 1
fi

echo "Uitstekend! Je hebt het complete network troubleshooting scenario succesvol voltooid en alle network debugging vaardigheden beheerst."
exit 0