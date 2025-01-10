export CLUSTER_NAME=$(kubectl config view --minify --output 'jsonpath={.clusters[0].name}'| awk -F'/' '{print $2}')
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export NAMESPACE="kube-system"
export REGION="ap-northeast-2"

KARPENTER_VERSION_V=$(curl -sL "https://api.github.com/repos/aws/karpenter/releases/latest" | jq -r ".tag_name")
export KARPENTER_VERSION="${KARPENTER_VERSION_V/v}"
echo "Karpenter's Latest release version: $KARPENTER_VERSION"

TEMPOUT=$(mktemp)

# # Create the IAM Role and Instance profile for Karpenter Nodes
# curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml  > "${TEMPOUT}" \
# && aws cloudformation deploy \
#   --stack-name "Karpenter-${CLUSTER_NAME}" \
#   --template-file "${TEMPOUT}" \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --parameter-overrides "ClusterName=${CLUSTER_NAME}"

# # Add the Karpenter node role to the aws-auth configmap
# eksctl create iamidentitymapping \
#   --username system:node:{{EC2PrivateDNSName}} \
#   --cluster "${CLUSTER_NAME}" \
#   --arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}" \
#   --group system:bootstrappers \
#   --group system:nodes

# # Create KarpenterController IAM Role
# eksctl create iamserviceaccount \
#   --cluster "${CLUSTER_NAME}" --name karpenter --namespace $KARPENTER_NAMESPACE \
#   --role-name "${CLUSTER_NAME}-karpenter" \
#   --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
#   --role-only \
#   --approve

# echo Your Karpenter version is: $KARPENTER_VERSION
# helm registry logout public.ecr.aws
# helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" \
#   --namespace "${KARPENTER_NAMESPACE}" \
#   --set settings.clusterName=${CLUSTER_NAME} \
#   --set settings.interruptionQueue=${CLUSTER_NAME} \
#   --set tolerations[0].key=CriticalAddonsOnly \
#   --set tolerations[0].operator=Exists \
#   --set tolerations[0].effect=NoSchedule \
#   --set replicas=1 \


# eksctl create iamserviceaccount \
#   --cluster "${CLUSTER_NAME}" --name karpenter --namespace $NAMESPACE \
#   --role-name "${CLUSTER_NAME}-karpenter" \
#   --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
#   --override-existing-serviceaccounts \
#   --approve

# Logout of helm registry to perform an unauthenticated pull against the public ECR
helm registry logout public.ecr.aws
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "1.1.1" --namespace kube-system \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=karpenter \
  --set tolerations[0].key=CriticalAddonsOnly \
  --set tolerations[0].operator=Exists \
  --set tolerations[0].effect=NoSchedule \
  --set replicas=1 \
  --wait