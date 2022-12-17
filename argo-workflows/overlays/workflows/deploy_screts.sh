#!/bin/bash

kubectl create secret generic argo-artifacts -n workflows \
                --dry-run=client \
                --from-literal=accesskey=minio \
                --from-literal=secretkey=minio123 -o yaml \
                | kubeseal  --controller-namespace kubeseal \
                            --controller-name sealed-secrets \
                            --format yaml > argo-artifacts-sealedsecret.yaml

mv *sealedsecret.yaml secrets