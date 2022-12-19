## install argo workflows with artifact repository configured
```kustomize build  base | kubectl apply -f -```

# Create a Secret based on existing credentials
The workflows require a number of secrets to function properly:
1. argo-artifacts
2. git-known-hosts
3. git-ssh
4. github-access
5. regcred

## apply docker reg credentials
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/david/.docker/config.json --type=kubernetes.io/dockerconfigjson -n workflows

## apply git-ssh secret
kubectl -n workflows create secret generic git-ssh --from-file=key=/home/david/.ssh/id_ed25519

kubectl -n workflows create secret generic git-known-hosts --from-file=ssh_known_hosts=/home/david/.ssh/known_hosts

## configure argo artifacts minio storage
kubectl -n workflows create secret generic argo-artifacts --from-literal=username=minio --from-literal=password=minio123

## apply github-access secret that encode the personal access token
kubectl create secret generic github-access -n workflows --dry-run=client --from-file=token=.env -o json > github-access.json

kubeseal --controller-namespace kubeseal \
         --controller-name sealed-secrets \
        < github-access.json  > github-access-sealedsecret.json

kubectl apply -f github-access-sealedsecret.json -n workflows

# Open a port-forward so you can access the UI:
kubectl -n argo port-forward deployment/argo-server 2746:2746
xdg-open https://localhost:2746

This will serve the UI on https://localhost:2746. Due to the self-signed certificate, you will receive a TLS error which you will need to manually approve.


## seldon
The wine-model docker file is huge and I have not found a way to reduce the size yet. It seems like Minikube can't pull large images. A workaround is to run:
```
minikube ssh
docker pull foxy7887/wine-model:v10
```
I don't know if the same issue will be present in EKS...we will see

## to list the model when it comes up and get details on the internal URL of the prediction service
```
kubectl get sdep -n workflows

kubectl -n workflows get sdep seldon-deployment-train-pipeline -o json | jq .status
```

Docs and predictions can be access with the following url:

This can be accessed through the endpoint http://<ingress_url>/seldon/<namespace>/<model-name>/api/v1.0/doc/ which will allow you to send requests directly through your browser.

Locally we can port-forward to the istio-ingressgateway service and send requests to that:
```
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```
Send requests to our prediction service
```
curl -X POST      -H 'Content-Type: application/json'  \
    -d '{"data": { "ndarray": [[1,2,3,4,5]]}}'   \
        http://localhost:8080/seldon/workflows/seldon-deployment-deploy-wine-clf-cp6nf/api/v1.0/predictions
        
{"data":{"names":["t:0","t:1","t:2","t:3","t:4"],"ndarray":[[1,2,3,4,5]]},"meta":{"requestPath":{"wine-clf":"foxy7887/wine-model:v10"}}}
```

The internal url to reach the prediction service is:
http://seldon-model.workflows.svc.cluster.local:8000/api/v1.0/predictions

kubectl -n workflows describe sdep mysdep


curl  -X POST http://localhost:9998/api/v1.0/predictions \
-H 'Content-Type: application/json' \
-d  '{ "data": { "ndarray": [[2,1,2,3,4]] } }' | json_pp





kubectl create secret generic argo-artifacts -n workflows \
                --from-literal=accesskey=minio \
                --from-literal=secretkey=minio123 -o yaml