https://github.com/kubeflow/katib/tree/master/examples/v1beta1/argo


port-forward to the katib UI
```
kubectl port-forward svc/katib-ui  8888:80 -n kubeflow
xdg-open http://localhost:8888/katib
```