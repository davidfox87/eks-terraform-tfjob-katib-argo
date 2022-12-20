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
## Our infrastructure in aws will look like this (substitute gRPC traffic with HTTPS traffic):
![AWS infra](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/images/pattern-img/abf727c1-ff8b-43a7-923f-bce825d1b459/images/281936fa-bc43-4b4e-a343-ba1eab97df38.png)


## Clean up your workspace

Delete the application in argo-cd

Then destroy all infrastructure in AWS using
```
terraform destroy
```



