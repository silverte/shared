helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "1.1.1" --namespace "kube-system" \
  --set "settings.clusterName=eks-esp-shared" \
  --set "settings.interruptionQueue=eks-esp-shared" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=karpenter \
  --set tolerations[0].key=CriticalAddonsOnly \
  --set tolerations[0].operator=Exists \
  --set tolerations[0].effect=NoSchedule \
  --set replicas=1
