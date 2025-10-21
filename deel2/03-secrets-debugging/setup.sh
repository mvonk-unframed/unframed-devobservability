#!/bin/bash

# Wacht tot Kubernetes cluster klaar is
echo "Wachten tot Kubernetes cluster klaar is..."
while ! kubectl get nodes &> /dev/null; do
  sleep 2
done

echo "Kubernetes cluster is klaar!"

# Maak secrets namespace aan
kubectl create namespace secrets --dry-run=client -o yaml | kubectl apply -f -

echo "Aanmaken van verschillende secrets voor debugging..."

# 1. Database credentials secret
kubectl create secret generic database-credentials \
  --from-literal=username=dbuser \
  --from-literal=password=supersecret123 \
  --from-literal=host=postgres.database.svc.cluster.local \
  --from-literal=port=5432 \
  -n secrets

# 2. API keys secret
kubectl create secret generic api-keys \
  --from-literal=stripe-key=sk_test_123456789 \
  --from-literal=sendgrid-key=SG.abcdef123456 \
  --from-literal=jwt-secret=my-super-secret-jwt-key \
  -n secrets

# 3. TLS certificate secret (self-signed voor demo)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=webapp.example.com/O=webapp"

kubectl create secret tls webapp-tls \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n secrets

# 4. Docker registry secret
kubectl create secret docker-registry docker-credentials \
  --docker-server=registry.example.com \
  --docker-username=registryuser \
  --docker-password=registrypass123 \
  --docker-email=user@example.com \
  -n secrets

# 5. ConfigMap met non-sensitive data (voor vergelijking)
kubectl create configmap app-config \
  --from-literal=app-name=webapp \
  --from-literal=environment=production \
  --from-literal=debug=false \
  --from-literal=log-level=info \
  -n secrets

# 6. Secret met verkeerde/oude credentials (voor troubleshooting)
kubectl create secret generic broken-db-credentials \
  --from-literal=username=wronguser \
  --from-literal=password=wrongpassword \
  --from-literal=host=nonexistent.database.svc.cluster.local \
  --from-literal=port=5432 \
  -n secrets

echo "Deployen van applicaties die secrets gebruiken..."

# 7. Web applicatie die database credentials gebruikt
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.20
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: host
        - name: STRIPE_KEY
          valueFrom:
            secretKeyRef:
              name: api-keys
              key: stripe-key
        volumeMounts:
        - name: tls-certs
          mountPath: /etc/ssl/certs/webapp
          readOnly: true
        - name: config
          mountPath: /etc/config
          readOnly: true
      volumes:
      - name: tls-certs
        secret:
          secretName: webapp-tls
      - name: config
        configMap:
          name: app-config
      imagePullSecrets:
      - name: docker-credentials
EOF

# 8. Broken applicatie die verkeerde credentials gebruikt
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-webapp
  namespace: secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken-webapp
  template:
    metadata:
      labels:
        app: broken-webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.20
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: broken-db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: broken-db-credentials
              key: password
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: broken-db-credentials
              key: host
EOF

# 9. Pod die secret als volume mount gebruikt
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
  namespace: secrets
spec:
  containers:
  - name: app
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: database-credentials
EOF

echo "Wachten tot pods gestart zijn..."
sleep 20

# Cleanup temp files
rm -f /tmp/tls.key /tmp/tls.crt

echo "Setup voltooid! Secrets en applicaties zijn klaar voor debugging."
echo "Secrets overzicht:"
kubectl get secrets -n secrets