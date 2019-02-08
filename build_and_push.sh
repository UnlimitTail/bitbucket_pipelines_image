#!/bin/sh
VERSION=0.0.1
TAG=utail/bitbucket_pipelines_image

docker build --tag=$TAG:$VERSION .
docker push $TAG:$VERSION
docker push $TAG:latest
