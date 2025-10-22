# 1
kubectl create ns ns-10

# 2
kubectl label ns webapp purpose=frontend
kubectl create quota quota -n webapp --hard cpu=1,memory=1G

# 3
kubectl create secret generic resource-count \
--from-literal=webapp-pods=3 \
--from-literal=database-services=1 \
--from-literal=monitoring-deployments=2

# 4
kubectl config set-context --current --namespace=frontend

# 5
kubectl create secret generic cluster-analysis \
--from-literal=total-pods=24 \
--from-literal=total-deployments=13 \
--from-literal=total-services=6