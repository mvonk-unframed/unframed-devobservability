#!/bin/bash

# Controleer of er een namespace is aangemaakt die begint met "ns-"
created_namespace=$(kubectl get namespaces --no-headers | grep "^ns-" | head -1 | awk '{print $1}')

if [ -z "$created_namespace" ]; then
    exit 1
fi

# Extraheer het getal en controleer of het logisch is (tussen 5 en 20)
namespace_number=$(echo "$created_namespace" | sed 's/ns-//')
if [ "$namespace_number" -lt 5 ] || [ "$namespace_number" -gt 20 ]; then
    exit 1
fi

exit 0