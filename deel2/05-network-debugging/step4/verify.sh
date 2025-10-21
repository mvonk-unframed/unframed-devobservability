#!/bin/bash

# Controleer of de gebruiker ingress en load balancer debugging heeft uitgevoerd

# Controleer of network namespace bestaat
if ! kubectl get namespace network &> /dev/null; then
    echo "Network namespace niet gevonden."
    exit 1
fi

# Controleer of ingress resources bestaan
ingress_count=$(kubectl get ingress -n network --no-headers 2>/dev/null | wc -l)
if [ "$ingress_count" -eq 0 ]; then
    echo "Geen ingress resources gevonden."
    exit 1
fi

# Controleer of ingress-nginx namespace bestaat
if ! kubectl get namespace ingress-nginx &> /dev/null; then
    echo "Ingress-nginx namespace niet gevonden."
    exit 1
fi

# Controleer of ingress controller pods draaien
controller_pods=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | wc -l)
if [ "$controller_pods" -eq 0 ]; then
    echo "Geen ingress controller pods gevonden."
    exit 1
fi

# Test of frontend-ingress bestaat
if ! kubectl get ingress frontend-ingress -n network &> /dev/null; then
    echo "Frontend ingress niet gevonden."
    exit 1
fi

# Test of broken-ingress bestaat
if ! kubectl get ingress broken-ingress -n network &> /dev/null; then
    echo "Broken ingress niet gevonden."
    exit 1
fi

# Test of api-ingress bestaat
if ! kubectl get ingress api-ingress -n network &> /dev/null; then
    echo "API ingress niet gevonden."
    exit 1
fi

# Controleer ingress controller service
if ! kubectl get service ingress-nginx-controller -n ingress-nginx &> /dev/null; then
    echo "Ingress controller service niet gevonden."
    exit 1
fi

# Test ingress controller IP
ingress_ip=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -z "$ingress_ip" ]; then
    echo "Kon ingress controller IP niet ophalen."
    exit 1
fi

# Test debug pod status
debug_pod_status=$(kubectl get pod debug-pod -n network --no-headers 2>/dev/null | awk '{print $3}')
if [ "$debug_pod_status" != "Running" ]; then
    echo "Debug pod is niet running voor ingress testing."
    exit 1
fi

# Test frontend ingress connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: frontend.local" http://$ingress_ip &> /dev/null; then
    echo "Frontend ingress connectivity faalt."
    exit 1
fi

# Test API ingress connectivity
if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: api.local" http://$ingress_ip/api &> /dev/null; then
    echo "API ingress connectivity faalt."
    exit 1
fi

# Test broken ingress (zou moeten falen of nu werken als gerepareerd)
kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: broken.local" http://$ingress_ip &> /dev/null
broken_ingress_result=$?

# Controleer of TLS secret is aangemaakt (als TLS ingress is gemaakt)
if kubectl get secret secure-tls -n network &> /dev/null; then
    # Test TLS ingress
    if ! kubectl get ingress secure-ingress -n network &> /dev/null; then
        echo "Secure ingress niet gevonden terwijl TLS secret wel bestaat."
        exit 1
    fi
    
    # Test HTTPS connectivity
    kubectl exec debug-pod -n network -- curl -s -k --connect-timeout 5 -H "Host: secure.local" https://$ingress_ip &> /dev/null
fi

# Test NodePort service
if ! kubectl get service frontend-nodeport -n network &> /dev/null; then
    echo "Frontend NodePort service niet gevonden."
    exit 1
fi

# Controleer NodePort configuratie
nodeport=$(kubectl get service frontend-nodeport -n network -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
if [ "$nodeport" != "30080" ]; then
    echo "NodePort heeft niet de verwachte waarde 30080."
    exit 1
fi

# Test NodePort connectivity
node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}' 2>/dev/null)
if [ -n "$node_ip" ]; then
    kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 http://$node_ip:30080 &> /dev/null
    # Dit kan falen afhankelijk van cluster setup, dus niet kritiek
fi

# Controleer ingress backend services bestaan
frontend_service_exists=$(kubectl get service frontend-service -n network &> /dev/null && echo "true" || echo "false")
backend_service_exists=$(kubectl get service backend-service -n network &> /dev/null && echo "true" || echo "false")

if [ "$frontend_service_exists" != "true" ]; then
    echo "Frontend service bestaat niet voor ingress backend."
    exit 1
fi

if [ "$backend_service_exists" != "true" ]; then
    echo "Backend service bestaat niet voor ingress backend."
    exit 1
fi

# Test of ingress rules correct zijn geconfigureerd
frontend_ingress_host=$(kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$frontend_ingress_host" != "frontend.local" ]; then
    echo "Frontend ingress host niet correct geconfigureerd."
    exit 1
fi

api_ingress_host=$(kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$api_ingress_host" != "api.local" ]; then
    echo "API ingress host niet correct geconfigureerd."
    exit 1
fi

# Test of broken ingress is gerepareerd (als patch is toegepast)
broken_backend_service=$(kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$broken_backend_service" = "frontend-service" ]; then
    # Ingress is gerepareerd, test connectivity
    if ! kubectl exec debug-pod -n network -- curl -s --connect-timeout 5 -H "Host: broken.local" http://$ingress_ip &> /dev/null; then
        echo "Gerepareerde broken ingress werkt nog steeds niet."
        exit 1
    fi
fi

echo "Uitstekend! Je hebt ingress en load balancer debugging beheerst en begrijpt hoe externe toegang tot Kubernetes services werkt."
exit 0