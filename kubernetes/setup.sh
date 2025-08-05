#!/bin/bash

export CLUSTER_NAME=`kubectl config current-context`
export CLUSTER_DOMAIN=$CLUSTER_NAME.kat.cmmaz.cloud

export NAMESPACE=stateful-poc

kubectl create namespace $NAMESPACE

helm pull oci://quay.io/bamoe/consoles-helm-chart --version=9.2.1-ibm-0005 --untar
helm install -n $NAMESPACE my-bamoe-consoles ./consoles-helm-chart --values ./consoles-helm-chart/values-kubernetes.yaml --set global.kubernetesClusterDomain="$CLUSTER_DOMAIN"

sed -i -e "s/MYCLUSTER/$CLUSTER_NAME/g" kubernetes/ingress-management-console.yaml 

kubectl apply -f kubernetes/ingress-management-console.yaml 
echo "It should actually be available at https://bamoe-management-console.$CLUSTER_DOMAIN"

sed -i -e "s/$CLUSTER_NAME/MYCLUSTER/g" kubernetes/ingress-management-console.yaml 

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n $NAMESPACE my-pg bitnami/postgresql --set postgresqlPassword=admin --set postgresqlUsername=admin --set postgresql.auth.database=bamoe --set postgresql.auth.username=myuser --set postgresql.auth.password=mypassword

# Install Prmetheus Operator so we can deploy with kie-addons-quarkus-monitoring-prometheus
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml

USER=$(whoami)
export USER=${USER//./} 
