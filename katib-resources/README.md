https://github.com/kubeflow/katib/tree/master/examples/v1beta1/argo


port-forward to the katib UI
```
kubectl port-forward svc/katib-ui  8080:80 -n kubeflow
xdg-open http://localhost:8080/katib
```


# Run a Katib Hyperparameter tuning session, which triggers argo-workflows
Each workflow consists of:
1. pre-preprocessing step
2. model training

```
kubectl apply -f katib-argo-random.yaml
kubectl logs po/katib-argo-workflow-bttwn4mb-model-training-1322055212 -n argo
```

## 2 cool things:
1. You can view the logs of the containers in each workflow step
2. You can view the results of each workflow hyperparameter tuning trial in the Katib UI.