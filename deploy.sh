#!/bin/bash
set -e

# ─── CONFIG — edit these ───────────────────────────────────────────────────
AWS_REGION="ap-south-1"           # e.g. ap-south-1 for Mumbai
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="k8s-node-app"
CLUSTER_NAME="my-eks-cluster"
IMAGE_TAG="latest"
# ───────────────────────────────────────────────────────────────────────────

ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"

echo "==> Step 1: Create ECR repo (skip if exists)"
aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION 2>/dev/null || \
  aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION

echo "==> Step 2: Docker login to ECR"
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "==> Step 3: Build and push Docker image"
cd app
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $ECR_URI:$IMAGE_TAG
docker push $ECR_URI:$IMAGE_TAG
cd ..

echo "==> Step 4: Update image in deployment manifest"
sed -i.bak "s|YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION|g" k8s/deployment.yaml
rm -f k8s/deployment.yaml.bak

echo "==> Step 5: Update kubeconfig for EKS"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

echo "==> Step 6: Apply Kubernetes manifests"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

echo "==> Step 7: Wait for rollout"
kubectl rollout status deployment/node-app

echo "==> Step 8: Get LoadBalancer URL"
echo "Waiting for external IP (takes ~60s)..."
sleep 60
kubectl get service node-app-service
