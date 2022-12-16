
This repo shows how to train a model on CPU instances in a Kubernetes cluster by using Kubeflow/TFJob training operator and a Deep Learning Container. 

TFJob is the Kubeflow implementation of Kubernetes custom resource that is used to run (distributed) TensorFlow training jobs on Kubernetes.

This tutorial guides you through training a classification model on MNIST with Keras in a single node CPU instance running a container from Deep Learning Containers managed by Kubeflow.


1. Create Kind cluster with Kubernetes v1.25.2
```
kind create cluster --image kindest/node:v1.25.2
echo -e "\nKind cluster has been created\n"
```

2. Set context for kubectl
```
kubectl config use-context kind-kind
```

3. Wait until Kubernetes Nodes will be ready.
```
TIMEOUT=30m
kubectl wait --for=condition=ready --timeout=${TIMEOUT} node kind-control-plane

kubectl get nodes
```

4. Deploy TFJob operator standalone
```
kubectl apply -k "github.com/kubeflow/training-operator/manifests/overlays/standalone?ref=v1.5.0"
```

5. Containerize the MNIST classifier code. Build and push the docker image to ECR by running ```./build-and-push.sh``` in the the mnist folder.

6. To start training, deploy the TFJob configuration file using kubectl.
```
kubectl create -f tf.yaml -n ${NAMESPACE}
```


# Hyperparameter tuning

7. Deploy Katib components.
```
echo -e "\nDeploying Katib components\n"
kubectl apply -k "github.com/kubeflow/katib.git/manifests/v1beta1/installs/katib-standalone?ref=master"
```

# Wait until all Katib pods are running.
```
kubectl wait --for=condition=ready --timeout=${TIMEOUT} -l "katib.kubeflow.org/component in (controller,db-manager,mysql,ui)" -n kubeflow pod

echo -e "\nKatib has been deployed"
kubectl get pods -n kubeflow
```
