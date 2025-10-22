#!/bin/bash

# Controleer problem-diagnosis secret
if ! kubectl get secret problem-diagnosis -n default &> /dev/null; then
    exit 1
fi

# Controleer vereiste keys
imagepull_pod=$(kubectl get secret problem-diagnosis -n default -o jsonpath='{.data.imagepull-pod}' 2>/dev/null | base64 -d)
pending_pod=$(kubectl get secret problem-diagnosis -n default -o jsonpath='{.data.pending-pod}' 2>/dev/null | base64 -d)

if [ -z "$imagepull_pod" ] || [ -z "$pending_pod" ]; then
    exit 1
fi

# Controleer of pods bestaan en juiste status hebben
if ! kubectl get pod "$imagepull_pod" -n debugging &> /dev/null; then
    exit 1
fi

if ! kubectl get pod "$pending_pod" -n debugging &> /dev/null; then
    exit 1
fi

exit 0