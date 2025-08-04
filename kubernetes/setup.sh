#!/bin/bash

export CLUSTER_NAME=`kubectl config current-context`
export CLUSTER_DOMAIN=$CLUSTER_NAME.kat.cmmaz.cloud

export NAMESPACE=stateful-poc

kubectl create namespace $NAMESPACE

helm pull oci://quay.io/bamoe/consoles-helm-chart --version=9.2.1-ibm-0005 --untar
helm install -n $NAMESPACE my-bamoe-consoles ./consoles-helm-chart --values ./consoles-helm-chart/values-kubernetes.yaml --set global.kubernetesClusterDomain="$CLUSTER_DOMAIN"


helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n $NAMESPACE my-pg bitnami/postgresql --set postgresqlPassword=admin --set postgresqlUsername=admin 

kubectl apply -f kubernetes/ingress-management-console.yaml 
echo "It should actually be available at https://bamoe-management-console.$CLUSTER_DOMAIN"