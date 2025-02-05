#!/bin/bash
export CLUSTER_NAME=$(kubectl config view --minify --output 'jsonpath={.clusters[0].name}'| awk -F'/' '{print $2}')
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export NAMESPACE="kube-system"
export REGION="ap-northeast-2"

aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name aws-s3-csi-driver \
  --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/role-esp-shared-s3-csi-driver \
  --region $REGION \
  --configuration-values '{
    "controller": {
      "tolerations": [
        {
          "key": "CriticalAddonsOnly",
          "operator": "Exists",
          "effect": "NoSchedule"
        }
      ]
    },
    "node": {
      "tolerations": [
        {
          "key": "CriticalAddonsOnly",
          "operator": "Exists",
          "effect": "NoSchedule"
        }
      ]
    }
  }'