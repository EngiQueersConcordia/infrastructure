#!/usr/bin/env bash

echo -e "\n=== cilium-pre-flight-check READY pods should match cilium CURRENT pods ==="
kubectl get daemonset -n kube-system | sed -n '1p;/cilium/p'
echo -e "=== cilium-pre-flight-check READY pods should match cilium CURRENT pods ===\n"

echo -e "\n=== READY should be 1/1 ==="
kubectl get deployment -n kube-system cilium-pre-flight-check
echo -e "=== READY should be 1/1 ===\n"
