#!/bin/bash

# aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 880572800141.dkr.ecr.us-west-1.amazonaws.com

# [ $? -eq 0 ] && docker build -t mnist-model .
# [ $? -eq 0 ] && docker tag mnist-model:latest 880572800141.dkr.ecr.us-west-1.amazonaws.com/mnist-model:latest
# [ $? -eq 0 ] && docker push 880572800141.dkr.ecr.us-west-1.amazonaws.com/mnist-model:latest


#!/bin/bash -e

docker login --username=foxy7887 -p xx!

image_name=foxy7887/mnist-model
image_tag=v15
full_image_name=${image_name}:${image_tag}

cd "$(dirname "$0")" 
docker build -t "${full_image_name}" .
docker push "$full_image_name"

# Output the strict image name, which contains the sha256 image digest
docker inspect --format="{{index .RepoDigests 0}}" "${full_image_name}"

docker image rm "${full_image_name}"

