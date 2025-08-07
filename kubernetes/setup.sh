#!/bin/bash

export CLUSTER_NAME=`kubectl config current-context`
export CLUSTER_DOMAIN=$CLUSTER_NAME.kat.cmmaz.cloud

export NAMESPACE=stateful-poc

kubectl create namespace $NAMESPACE

helm pull oci://quay.io/bamoe/consoles-helm-chart --version=9.2.1-ibm-0005 --untar
helm install \
    -n $NAMESPACE my-bamoe-consoles ./consoles-helm-chart \
    --values ./kubernetes/values-kubernetes.yaml \
    --set global.kubernetesClusterDomain="$CLUSTER_DOMAIN" \
    --set ingress.className=null # To set this property we need to use our modified values-kubernetes.yaml file. We could use a documented property when bug is fixed. We need to set ingressClass to null for it to work in our cluster.

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n $NAMESPACE my-pg bitnami/postgresql --set postgresqlPassword=admin --set postgresqlUsername=admin --set postgresql.auth.database=bamoe --set postgresql.auth.username=myuser --set postgresql.auth.password=mypassword

helm pull oci://quay.io/bamoe/canvas-helm-chart --version=9.2.1-ibm-0005 --untar
helm install -n $NAMESPACE  my-bamoe-canvas ./canvas-helm-chart --values ./kubernetes/canvas-values-kubernetes.yaml --set global.kubernetesClusterDomain="$CLUSTER_DOMAIN"

# Install Prmetheus Operator so we can deploy with kie-addons-quarkus-monitoring-prometheus
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml

USER=$(whoami)
export USER=${USER//./} 
