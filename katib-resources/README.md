https://github.com/kubeflow/katib/tree/master/examples/v1beta1/argo


port-forward to the katib UI
```
kubectl port-forward svc/katib-ui  8080:80 -n kubeflow
xdg-open http://localhost:8080/katib
```