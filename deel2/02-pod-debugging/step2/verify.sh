#!/bin/bash

# Controleer resource-analysis secret
if ! kubectl get secret resource-analysis -n default &> /dev/null; then
    exit 1
fi

# Controleer vereiste keys
highest_cpu=$(kubectl get secret resource-analysis -n default -o jsonpath='{.data.highest-cpu-pod}' 2>/dev/null | base64 -d)
highest_memory=$(kubectl get secret resource-analysis -n default -o jsonpath='{.data.highest-memory-pod}' 2>/dev/null | base64 -d)
node_count=$(kubectl get secret resource-analysis -n default -o jsonpath='{.data.total-node-count}' 2>/dev/null | base64 -d)

if [ -z "$highest_cpu" ] || [ -z "$highest_memory" ] || [ -z "$node_count" ]; then
    exit 1
fi

# Controleer of pods bestaan
if ! kubectl get pod "$highest_cpu" -n debugging &> /dev/null; then
    exit 1
fi

if ! kubectl get pod "$highest_memory" -n debugging &> /dev/null; then
    exit 1
fi

exit 0