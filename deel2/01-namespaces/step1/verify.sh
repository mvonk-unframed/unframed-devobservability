#!/bin/bash

# Controleer of er een namespace is aangemaakt die begint met "ns-"
created_namespace=$(kubectl get namespaces --no-headers | grep "^ns-" | tail -1 | awk '{print $1}')

if [ -z "$created_namespace" ]; then
    exit 1
fi

namespace_count=$(kubectl get ns --no-headers | wc -l)
namespace_number=$(echo "$created_namespace" | sed 's/ns-//')
if [ "$namespace_number" -ne $((namespace_count - 1)) ]; then
    exit 1
fi

exit 0