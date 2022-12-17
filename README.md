# Training Tensorflow/Keras Deep Learning Models using TFJob on Kubernetes clusters
This repo shows how to train a model on CPU instances in a Kubernetes cluster by using Kubeflow/TFJob training operator and a Deep Learning Container. 

TFJob is the Kubeflow implementation of Kubernetes custom resource that is used to run (distributed) TensorFlow training jobs on Kubernetes.

This tutorial guides you through training a classification model on MNIST with Keras in a single node CPU instance running a container from Deep Learning Containers managed by Kubeflow.


1. Create Kind cluster with Kubernetes v1.25.2
```
kind create cluster --config kind-config.yaml
echo -e "\nKind cluster has been created\n"
```

2. Set context for kubectl
```
kubectl config use-context kind-kind
```


3. Deploy TFJob operator standalone
```
kubectl apply -k "github.com/kubeflow/training-operator/manifests/overlays/standalone?ref=v1.5.0"
```

5. Containerize the MNIST classifier code. Build and push the docker image to ECR by running ```./build-and-push.sh``` in the the mnist folder.

6. create the secret to be referenced by imagePullSecrets in the tf-job.yaml
```
kubectl create secret docker-registry regcred \
  --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=default
```


6. To start training, deploy the TFJob configuration file using kubectl.
```
kubectl apply -f pvc.yaml
kubectl apply -f tf-job.yaml
```

7. Watch the training process
```
kubectl describe tfjob tensorflow-training
kubectl logs --follow tensorflow-training-worker-0
kubectl logs po/tensorflow-training-worker-0
```

8. To remove the TFJob and associated pods
```
kubectl delete tfjob tensorflow-training
```

9. Get a shell to the container 
```
kubectl exec --stdin --tty tensorflow-training-worker-0 -- /bin/bash
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
