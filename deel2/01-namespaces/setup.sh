#!/bin/bash

# Wacht tot Kubernetes cluster klaar is
echo "Wachten tot Kubernetes cluster klaar is..."
while ! kubectl get nodes &> /dev/null; do
  sleep 2
done

echo "Kubernetes cluster is klaar!"

# Maak verschillende namespaces aan
echo "Aanmaken van namespaces..."

# Web applicatie namespace
kubectl create namespace webapp --dry-run=client -o yaml | kubectl apply -f -

# Database namespace  
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

# Monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Development namespace
kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -

# Production namespace
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

echo "Deployen van applicaties in verschillende namespaces..."

# Deploy web applicatie in webapp namespace
kubectl create deployment frontend --image=nginx:1.20 --replicas=2 -n webapp
kubectl create deployment backend --image=nginx:1.20 --replicas=1 -n webapp

# Deploy database in database namespace
kubectl create deployment postgres --image=postgres:13 --replicas=1 -n database
kubectl create deployment redis --image=redis:6 --replicas=1 -n database

# Deploy monitoring tools
kubectl create deployment prometheus --image=prom/prometheus:latest --replicas=1 -n monitoring
kubectl create deployment grafana --image=grafana/grafana:latest --replicas=1 -n monitoring

# Deploy development applicaties
kubectl create deployment dev-app --image=nginx:1.20 --replicas=1 -n development
kubectl create deployment test-app --image=nginx:1.20 --replicas=1 -n development

# Deploy production applicaties
kubectl create deployment prod-frontend --image=nginx:1.20 --replicas=3 -n production
kubectl create deployment prod-backend --image=nginx:1.20 --replicas=2 -n production

# Maak enkele services aan
kubectl expose deployment frontend --port=80 --target-port=80 -n webapp
kubectl expose deployment backend --port=8080 --target-port=80 -n webapp
kubectl expose deployment postgres --port=5432 --target-port=5432 -n database
kubectl expose deployment prometheus --port=9090 --target-port=9090 -n monitoring

# Quota last, cannot effect running pods
kubectl create quota monitoring-quota -n monitoring --hard=cpu=1,memory=1G

echo "Wachten tot alle pods gestart zijn..."
sleep 30

# Controleer status van alle deployments
echo "Controleren van deployment status..."
kubectl get deployments --all-namespaces

echo "Setup voltooid! Namespaces en applicaties zijn klaar voor verkenning."