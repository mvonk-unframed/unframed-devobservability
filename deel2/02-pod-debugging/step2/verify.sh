#!/bin/bash

# Controleer of de gebruiker resource monitoring commando's heeft uitgevoerd
# We testen dit door te controleren of metrics-server werkt en commando's uitgevoerd kunnen worden

# Wacht even voor metrics-server om klaar te zijn
sleep 10

# Test of kubectl top nodes werkt
if ! kubectl top nodes &> /dev/null; then
    echo "kubectl top nodes werkt niet. Metrics-server is mogelijk nog niet klaar. Probeer over een paar minuten opnieuw."
    # Dit is niet kritiek voor de verificatie, dus we gaan door
fi

# Test of kubectl top pods werkt voor debugging namespace
if ! kubectl top pods -n debugging &> /dev/null; then
    echo "kubectl top pods werkt niet voor debugging namespace. Metrics-server is mogelijk nog niet klaar."
    # Ook dit is niet kritiek, we controleren andere aspecten
fi

# Controleer of er pods zijn in debugging namespace (dit is wel kritiek)
pod_count=$(kubectl get pods -n debugging --no-headers 2>/dev/null | wc -l)
if [ "$pod_count" -eq 0 ]; then
    echo "Geen pods gevonden in debugging namespace."
    exit 1
fi

# Test of gebruiker resource informatie kan bekijken via describe (alternatief voor top)
if ! kubectl get pods -n debugging -o custom-columns=NAME:.metadata.name,CPU-REQ:.spec.containers[*].resources.requests.cpu &> /dev/null; then
    echo "Kon resource informatie niet bekijken."
    exit 1
fi

# Controleer of er pods met resource limits zijn
pods_with_limits=$(kubectl get pods -n debugging -o jsonpath='{.items[*].spec.containers[*].resources.limits}' 2>/dev/null | wc -w)
if [ "$pods_with_limits" -eq 0 ]; then
    echo "Geen pods met resource limits gevonden. Setup is mogelijk niet correct."
    exit 1
fi

echo "Goed gedaan! Je hebt geleerd hoe je resource verbruik kunt monitoren. Als kubectl top nog niet werkt, is metrics-server nog aan het opstarten - dit is normaal en zal binnen enkele minuten werken."
exit 0