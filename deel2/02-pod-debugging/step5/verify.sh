#!/bin/bash

# Controleer debugging-report secret
if ! kubectl get secret debugging-report -n default &> /dev/null; then
    exit 1
fi

# Controleer alle vereiste keys
imagepull_issue=$(kubectl get secret debugging-report -n default -o jsonpath='{.data.imagepull-issue}' 2>/dev/null | base64 -d)
pending_issue=$(kubectl get secret debugging-report -n default -o jsonpath='{.data.pending-issue}' 2>/dev/null | base64 -d)
crash_issue=$(kubectl get secret debugging-report -n default -o jsonpath='{.data.crash-issue}' 2>/dev/null | base64 -d)
oom_limit=$(kubectl get secret debugging-report -n default -o jsonpath='{.data.oom-limit}' 2>/dev/null | base64 -d)

if [ -z "$imagepull_issue" ] || [ -z "$pending_issue" ] || [ -z "$crash_issue" ] || [ -z "$oom_limit" ]; then
    exit 1
fi

# Controleer debugging-workflow ConfigMap
if ! kubectl get configmap debugging-workflow -n default &> /dev/null; then
    exit 1
fi

exit 0