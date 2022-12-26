# Installing Argo-cd 
[Getting started with ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/)
From the applications/argocd folder:
```
kustomize build | kubectl apply -f -

kubectl port-forward svc/argocd-server -n argocd 9444:443

xdg-open https://localhost:9444
```

The API server can then be accessed using https://localhost:9443

```
kubectl get secret argocd-initial-admin-secret -n argocd -o yaml
echo cTNoNnFxdEVLVm42T2x3VQ== | base64 --decode
```
Take the decoded password and login to the ui
