#!/bin/bash

# Wacht tot Kubernetes cluster klaar is
echo "Wachten tot Kubernetes cluster klaar is..."
while ! kubectl get nodes &> /dev/null; do
  sleep 2
done

echo "Kubernetes cluster is klaar!"

# Maak debugging namespace aan
kubectl create namespace debugging --dry-run=client -o yaml | kubectl apply -f -

echo "Deployen van verschillende pod scenario's voor debugging..."

# 1. Werkende pods
kubectl create deployment healthy-app --image=nginx:1.20 --replicas=2 -n debugging
kubectl create deployment working-redis --image=redis:6 --replicas=1 -n debugging

# 2. Pod met verkeerde image (ImagePullBackOff)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-image
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken-image
  template:
    metadata:
      labels:
        app: broken-image
    spec:
      containers:
      - name: app
        image: nginx:nonexistent-tag
        ports:
        - containerPort: 80
EOF

# 3. Pod met te hoge resource requests (Pending)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hungry
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-hungry
  template:
    metadata:
      labels:
        app: resource-hungry
    spec:
      containers:
      - name: app
        image: nginx:1.20
        resources:
          requests:
            memory: "10Gi"
            cpu: "8"
          limits:
            memory: "10Gi"
            cpu: "8"
EOF

# 4. Pod met memory limit die OOMKilled wordt
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-hog
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-hog
  template:
    metadata:
      labels:
        app: memory-hog
    spec:
      containers:
      - name: app
        image: progrium/stress
        args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
        resources:
          limits:
            memory: "100Mi"
          requests:
            memory: "50Mi"
EOF

# 5. Pod die crasht (CrashLoopBackOff)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crash-app
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: crash-app
  template:
    metadata:
      labels:
        app: crash-app
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sh", "-c", "echo 'Starting app...'; sleep 5; echo 'App crashed!'; exit 1"]
EOF

# 6. Pod met failing readiness probe
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: failing-readiness
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: failing-readiness
  template:
    metadata:
      labels:
        app: failing-readiness
    spec:
      containers:
      - name: app
        image: nginx:1.20
        readinessProbe:
          httpGet:
            path: /nonexistent
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# 7. High CPU consuming pod
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-intensive
  namespace: debugging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-intensive
  template:
    metadata:
      labels:
        app: cpu-intensive
    spec:
      containers:
      - name: app
        image: progrium/stress
        args: ["--cpu", "1", "--timeout", "300s"]
        resources:
          limits:
            cpu: "500m"
          requests:
            cpu: "100m"
EOF

echo "Wachten tot pods in verschillende states zijn..."
sleep 45

# Installeer metrics-server voor kubectl top (als het nog niet bestaat)
if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo "Installeren van metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch metrics-server voor lokale ontwikkeling
    kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
      {
        "op": "add",
        "path": "/spec/template/spec/containers/0/args/-",
        "value": "--kubelet-insecure-tls"
      }
    ]'
    
    echo "Wachten tot metrics-server klaar is..."
    kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system
fi

echo "Setup voltooid! Verschillende pod debugging scenario's zijn klaar."
echo "Pods in verschillende states:"
kubectl get pods -n debugging