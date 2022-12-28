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

Kubernetes control plane is running at https://4B83993396E321DB0B75BD137A5B57B8.gr7.us-west-1.eks.amazonaws.com
CoreDNS is running at https://4B83993396E321DB0B75BD137A5B57B8.gr7.us-west-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Now verify that all three worker nodes are part of the cluster.
```
kubectl get nodes

NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-0-2-170.us-west-1.compute.internal   Ready    <none>   4m25s   v1.21.14-eks-fb459a0
ip-10-0-2-50.us-west-1.compute.internal    Ready    <none>   4m      v1.21.14-eks-fb459a0
ip-10-0-3-51.us-west-1.compute.internal    Ready    <none>   4m21s   v1.21.14-eks-fb459a0
```


Verify the aws-load-balancer-controller is installed
```
kubectl get deployment -n kube-system aws-load-balancer-controller

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           7m2s
```

## Patch the storage class so the efs-provisioner is the default
```
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass efs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'



```
### Test EFS
For more info on efs-csi-driver see:
https://github.com/kubernetes-sigs/aws-efs-csi-driver

for info on how to set up efs with eks:
https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

```
kubectl apply -f efs-pod.yaml
kubectl get pvc
kubectl get pv
kubectl exec --stdin --tty efs-app  -- /bin/sh
cd /data
tail -f out
```

### To test s3 access by the workflow-sa service-account
```
kubectl apply -f aws-cli-pod.yaml
kubectl -n workflows exec -it aws-cli -- aws sts get-caller-identity                
kubectl exec -it aws-cli -n workflows -- aws s3 ls s3://argo-artifacts-880572800141
```

# use ArgoCD to deploy resources and manage cluster
In ```apps/argo-cd/overlays/staging``` folder:
```
kustomize build | kubectl apply -f -

kubectl port-forward svc/argocd-server -n argocd 9444:443

xdg-open https://localhost:9444
```

Get the login password:
```
kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r '.data.password' | base64 -d
```

## Apply project and apps
In top-level directory:
```
kubectl apply -f projects.yaml
kubectl apply -f apps.yaml
```

Hope for the best...


## Clean up your workspace

Delete the application in argo-cd

Then destroy all infrastructure in AWS using
```
terraform destroy
```



