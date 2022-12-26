# Deploying an AWS EKS cluster
Our AWS infrastructure will consist of the following:

- EKS Cluster: AWS managed Kubernetes cluster of master servers
- EKS Node Group
- Associated VPC, Internet Gateway, Security Groups, and Subnets: Operator managed networking resources for the EKS Cluster and worker node instances
- Associated IAM Roles and Policies: Operator managed access resources for EKS and worker node instances

Run the following commands to deploy the EKS cluster:
```
terraform init
terraform get
terraform apply
```


First, get information about the cluster.
```
kubectl cluster-info
```

Now verify that all three worker nodes are part of the cluster.
```
kubectl get nodes
```


Verify the aws-load-balancer-controller is installed
```
kubectl get deployment -n kube-system aws-load-balancer-controller
```


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

## patch the storage class so the efs-provisioner is the default
```
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass efs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```
## Clean up your workspace

Delete the application in argo-cd

Then destroy all infrastructure in AWS using
```
terraform destroy
```



