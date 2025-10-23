#!/bin/bash

# Controleer of de gebruiker ingress analyse heeft uitgevoerd

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

# Controleer ingress backend services
frontend_backend=$(kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$frontend_backend" != "frontend-service" ]; then
    echo "Frontend ingress backend service is niet correct."
    exit 1
fi

api_backend=$(kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$api_backend" != "backend-service" ]; then
    echo "API ingress backend service is niet correct."
    exit 1
fi

# Controleer of backend services bestaan
if ! kubectl get service frontend-service -n network &> /dev/null; then
    echo "Frontend service (ingress backend) niet gevonden."
    exit 1
fi

if ! kubectl get service backend-service -n network &> /dev/null; then
    echo "Backend service (ingress backend) niet gevonden."
    exit 1
fi

# Controleer broken ingress backend (zou nonexistent-service moeten zijn)
broken_backend=$(kubectl get ingress broken-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$broken_backend" = "frontend-service" ]; then
    echo "Broken ingress is al gerepareerd - dit zou voor de oefening nog broken moeten zijn."
    # Niet kritiek, kan al gerepareerd zijn
fi

# Test ingress controller service
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

# Controleer poort configuratie
frontend_ingress_port=$(kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
frontend_service_port=$(kubectl get service frontend-service -n network -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)

if [ "$frontend_ingress_port" != "$frontend_service_port" ]; then
    echo "Frontend ingress en service poorten matchen niet."
    exit 1
fi

# Controleer of ingress-analysis secret is aangemaakt
if ! kubectl get secret ingress-analysis -n network &> /dev/null; then
    echo "Ingress-analysis secret niet aangemaakt."
    exit 1
fi

# Test ingress host configuratie
frontend_host=$(kubectl get ingress frontend-ingress -n network -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$frontend_host" != "frontend.local" ]; then
    echo "Frontend ingress host niet correct geconfigureerd."
    exit 1
fi

api_host=$(kubectl get ingress api-ingress -n network -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$api_host" != "api.local" ]; then
    echo "API ingress host niet correct geconfigureerd."
    exit 1
fi

echo "Uitstekend! Je hebt ingress analyse uitgevoerd en begrijpt hoe ingress gekoppeld is aan services en poorten."
exit 0