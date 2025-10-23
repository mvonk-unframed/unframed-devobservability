#!/bin/bash

# Controleer of de gebruiker de praktische troubleshooting oefening heeft voltooid

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Test of debug pod running is voor connectivity tests
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" != "Running" ]; then
    echo "Debug pod is niet running voor troubleshooting tests."
    exit 1
fi

# Test ingress controller IP
ingress_ip=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -z "$ingress_ip" ]; then
    echo "Kon ingress controller IP niet ophalen."
    exit 1
fi

# Test complete connectivity flow na troubleshooting
echo "Testing complete network flow na troubleshooting..."

# Test frontend flow (Ingress → Service → Pod)
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: frontend.local" http://$ingress_ip &> /dev/null; then
    echo "Frontend network flow faalt na troubleshooting."
    exit 1
fi

# Test API flow
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: api.local" http://$ingress_ip/api &> /dev/null; then
    echo "API network flow faalt na troubleshooting."
    exit 1
fi

# Test of broken ingress is gerepareerd
broken_backend_service=$(kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$broken_backend_service" = "frontend-service" ]; then
    # Ingress is gerepareerd, test connectivity
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: broken.local" http://$ingress_ip &> /dev/null; then
        echo "Gerepareerde broken ingress werkt nog steeds niet."
        exit 1
    fi
    echo "✅ Broken ingress succesvol gerepareerd."
else
    echo "❌ Broken ingress is niet gerepareerd."
    exit 1
fi

# Test of failing-readiness deployment is gerepareerd
failing_ready_pods=$(kubectl get pods -n network -l app=failing-readiness --no-headers 2>/dev/null | grep "1/1" | wc -l)
if [ "$failing_ready_pods" -gt 0 ]; then
    echo "✅ Failing-readiness pods zijn nu ready."
    
    # Test of service nu endpoints heeft
    failing_endpoints=$(kubectl get endpoints failing-readiness-service -n network --no-headers 2>/dev/null | awk '{print $2}')
    if [ "$failing_endpoints" != "<none>" ] && [ -n "$failing_endpoints" ]; then
        echo "✅ Failing-readiness service heeft nu endpoints."
    fi
else
    echo "❌ Failing-readiness pods zijn nog steeds niet ready."
    exit 1
fi

# Test service connectivity na reparaties
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://frontend-service &> /dev/null; then
    echo "Service connectivity naar frontend faalt."
    exit 1
fi

if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://backend-service:8080 &> /dev/null; then
    echo "Service connectivity naar backend faalt."
    exit 1
fi

# Test of alle services endpoints hebben
services_without_endpoints=$(kubectl get endpoints -n network | grep "<none>" | wc -l)
if [ "$services_without_endpoints" -gt 0 ]; then
    echo "Er zijn nog steeds services zonder endpoints."
    exit 1
fi

# Controleer of network-troubleshooting secret is aangemaakt
if ! kubectl get secret network-troubleshooting -n network &> /dev/null; then
    echo "Network-troubleshooting secret niet aangemaakt."
    exit 1
fi

# Test load balancing door meerdere requests
success_count=0
for i in {1..3}; do
    if kubectl exec debug-pod -n network -- curl -s --connect-timeout 3 -H "Host: frontend.local" http://$ingress_ip &> /dev/null; then
        ((success_count++))
    fi
done

if [ "$success_count" -eq 0 ]; then
    echo "Load balancing test faalde - geen succesvolle requests."
    exit 1
fi

# Controleer overall cluster health na troubleshooting
total_pods=$(kubectl get pods -n network --no-headers 2>/dev/null | wc -l)
running_pods=$(kubectl get pods -n network --no-headers 2>/dev/null | grep "Running" | wc -l)
ready_pods=$(kubectl get pods -n network --no-headers 2>/dev/null | grep "1/1\|2/2" | wc -l)

if [ "$running_pods" -eq 0 ]; then
    echo "Geen running pods gevonden na troubleshooting."
    exit 1
fi

if [ "$ready_pods" -eq 0 ]; then
    echo "Geen ready pods gevonden na troubleshooting."
    exit 1
fi

# Test ingress controller health
controller_running=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | grep "Running" | wc -l)
if [ "$controller_running" -eq 0 ]; then
    echo "Ingress controller is niet running."
    exit 1
fi

# Valideer dat alle drie de stappen zijn gevolgd
echo "✅ Stap 1: Ingress analyse - Ingress backend configuratie gecontroleerd"
echo "✅ Stap 2: Service analyse - Service selectors en endpoints gecontroleerd"
echo "✅ Stap 3: Pod analyse - Pod status en readiness gecontroleerd"
echo "✅ Problemen gerepareerd en end-to-end flow gevalideerd"

echo "Uitstekend! Je hebt de praktische troubleshooting oefening succesvol voltooid en alle network debugging vaardigheden beheerst."
exit 0