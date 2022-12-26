https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

# Changing the default storage class
To make the new EFS storage class the default for this cluster:
1. List the StorageClasses in your cluster:
```
kubectl get storageclass
```
2. Mark the default storage class as non-default
The default StorageClass has an annotation ```storageclass.kubernetes.io/is-default-class``` set to ```true```. Any other value or absense of the annotation is interpreted as ```false```.

3. To mark a StorageClass as non-default, you need to change its value to ```false```
```
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

where ```standard``` is the name of your chosen storage class.

4. Mark a StorageClass as default
Similar to the previous step, you need to add/set the annotation ```storageclass.kubernetes.io/is-default-class=true```
```
kubectl patch storageclass efs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```