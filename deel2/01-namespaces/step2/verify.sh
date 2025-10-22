#!/bin/bash

# Controleer labels op namespaces
webapp_label=$(kubectl get namespace webapp -o jsonpath='{.metadata.labels.purpose}' 2>/dev/null)

if [ "$webapp_label" != "frontend" ]; then
    exit 1
fi

# Extraheer de waarden voor CPU en geheugen
cpu_quota=$(kubectl get resourcequota -n webapp -o jsonpath='{.items[0].status.hard.cpu}')
mem_quota=$(kubectl get resourcequota -n webapp -o jsonpath='{.items[0].status.hard.memory}')

# Controleer of ze gelijk zijn aan 1 CPU en 1G RAM
if [[ "$cpu_quota" == "1" && "$mem_quota" == "1G" ]]; then
  exit 0
fi

exit 1