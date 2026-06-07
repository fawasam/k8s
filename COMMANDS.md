# DIAGRAM

You edited index.js  →  version "2.0.0"
         ↓
docker buildx build --platform linux/amd64   ← built for EC2 (amd64)
         ↓
docker push → ECR                            ← image stored in AWS
         ↓
kubectl rollout restart deployment/node-app  ← K8s starts rolling update
         ↓
K8s spins up new pod → waits for readinessProbe → removes old pod
(repeats for each pod, one at a time — no downtime)
         ↓
curl → {"version":"2.0.0"} ✅



# 1. Build & push
docker buildx build --platform linux/amd64 \
  -t 037049058245.dkr.ecr.ap-south-1.amazonaws.com/k8s-node-app:latest --push .

# 2. Deploy
kubectl rollout restart deployment/node-app

# 3. Verify
kubectl rollout status deployment/node-app