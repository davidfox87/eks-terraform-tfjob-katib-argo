# To test EFS

```
kubectl apply -f efs-pod.yaml
kubectl get pvc
kubectl get pv
kubectl exec --stdin --tty efs-app  -- /bin/sh
cd /data
tail -f out
```

# To test s3 access by the workflow-sa service-account
```
kubectl apply -f aws-cli-pod.yaml
kubectl -n workflows exec -it aws-cli -- aws sts get-caller-identity                
kubectl exec -it aws-cli -n workflows -- aws s3 ls s3://argo-artifacts-880572800141
```