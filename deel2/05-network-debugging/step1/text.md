# Stap 1: Service Discovery Overzicht

## Kubernetes Service Discovery Begrijpen

Service discovery is de manier waarop pods andere services kunnen vinden en ermee kunnen communiceren in een Kubernetes cluster.

## Bekijk Alle Services

Laten we beginnen met het bekijken van alle services in de network namespace:

```plain
kubectl get services -n network
```{{exec}}

## Service Types Begrijpen

Bekijk de verschillende service types:

```plain
kubectl get services -n network -o wide
```{{exec}}

### Service Types:
- **ClusterIP**: Alleen toegankelijk binnen het cluster
- **NodePort**: Toegankelijk via node IP en specifieke port
- **LoadBalancer**: External load balancer (cloud provider)

## DNS Service Discovery

Kubernetes biedt automatische DNS resolution voor services:

```plain
kubectl exec debug-pod -n network -- nslookup frontend-service.network.svc.cluster.local
```{{exec}}

Test ook de korte DNS naam:

```plain
kubectl exec debug-pod -n network -- nslookup frontend-service
```{{exec}}

## Service Endpoints Bekijken

Services gebruiken endpoints om te weten welke pods traffic moeten ontvangen:

```plain
kubectl get endpoints -n network
```{{exec}}

Bekijk gedetailleerde endpoint informatie:

```plain
kubectl describe endpoints frontend-service -n network
```{{exec}}

## Service Selectors Controleren

Bekijk hoe services pods selecteren via labels:

```plain
kubectl describe service frontend-service -n network
```{{exec}}

Vergelijk met de pod labels:

```plain
kubectl get pods -n network --show-labels
```{{exec}}

## Broken Service Analyseren

Bekijk de broken service die geen endpoints heeft:

```plain
kubectl get endpoints broken-service -n network
```{{exec}}

```plain
kubectl describe service broken-service -n network
```{{exec}}

Waarom heeft deze service geen endpoints? Bekijk de selector:

```plain
kubectl get service broken-service -n network -o yaml | grep -A 5 selector
```{{exec}}

Vergelijk met de daadwerkelijke pod labels:

```plain
kubectl get pods -n network -l app=broken-app --show-labels
```{{exec}}

## DNS Resolution Testing

Test DNS resolution voor verschillende services:

```plain
kubectl exec debug-pod -n network -- nslookup backend-service.network.svc.cluster.local
```{{exec}}

```plain
kubectl exec debug-pod -n network -- nslookup database-service.network.svc.cluster.local
```{{exec}}

## Service Discovery via Environment Variables

Kubernetes injecteert ook service informatie via environment variables:

```plain
kubectl exec debug-pod -n network -- env | grep SERVICE
```{{exec}}

## Cross-Namespace Service Discovery

Test service discovery naar andere namespaces:

```plain
kubectl exec debug-pod -n network -- nslookup kubernetes.default.svc.cluster.local
```{{exec}}

## NodePort Service Testing

Bekijk de NodePort service:

```plain
kubectl get service frontend-nodeport -n network
```{{exec}}

Test toegang via NodePort (van binnen het cluster):

```plain
kubectl exec debug-pod -n network -- curl -s http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):30080
```{{exec}}

## Service Discovery Troubleshooting Checklist

### 1. **Service Exists**
```bash
kubectl get service <service-name> -n <namespace>
```

### 2. **Service Has Endpoints**
```bash
kubectl get endpoints <service-name> -n <namespace>
```

### 3. **Selector Matches Pod Labels**
```bash
kubectl describe service <service-name>
kubectl get pods --show-labels
```

### 4. **DNS Resolution Works**
```bash
kubectl exec <pod> -- nslookup <service-name>
```

### 5. **Pods Are Ready**
```bash
kubectl get pods -o wide
```

## Wat Zie Je?

Analyseer de output en identificeer:
1. Welke services hebben endpoints?
2. Welke service heeft geen endpoints en waarom?
3. Hoe werkt DNS resolution voor services?
4. Wat is het verschil tussen ClusterIP en NodePort?

Deze informatie helpt je begrijpen hoe service discovery werkt en waar problemen kunnen ontstaan.