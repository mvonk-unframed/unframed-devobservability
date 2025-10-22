#!/bin/bash

# Controleer log-analysis secret
if ! kubectl get secret log-analysis -n default &> /dev/null; then
    exit 1
fi

# Controleer vereiste keys
crash_pod=$(kubectl get secret log-analysis -n default -o jsonpath='{.data.crash-pod}' 2>/dev/null | base64 -d)
error_message=$(kubectl get secret log-analysis -n default -o jsonpath='{.data.error-message}' 2>/dev/null | base64 -d)
restart_count=$(kubectl get secret log-analysis -n default -o jsonpath='{.data.restart-count}' 2>/dev/null | base64 -d)

if [ -z "$crash_pod" ] || [ -z "$error_message" ] || [ -z "$restart_count" ]; then
    exit 1
fi

# Controleer of crash pod bestaat
if ! kubectl get pod "$crash_pod" -n debugging &> /dev/null; then
    exit 1
fi

exit 0