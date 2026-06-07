# Kubernetes on AWS (EKS) — Node.js App

## ECS vs Kubernetes — mental model

| ECS concept        | Kubernetes equivalent        |
|--------------------|------------------------------|
| Task Definition    | Pod spec (inside Deployment) |
| Service            | Deployment + Service         |
| Desired count      | `replicas`                   |
| ALB Target Group   | Service (type: LoadBalancer) |
| Auto Scaling       | HorizontalPodAutoscaler      |
| ECR image          | same ECR image               |
| ECS Cluster        | EKS Cluster (nodes = EC2)    |

---

## Prerequisites — install these first

```bash
# 1. AWS CLI (you likely have this)
aws --version

# 2. eksctl — EKS cluster manager (like CDK for EKS)
brew install eksctl

# 3. kubectl — Kubernetes CLI
brew install kubectl

# 4. Verify
eksctl version && kubectl version --client
```

---

## Step-by-step

### 1. Create EKS Cluster

```bash
eksctl create cluster \
  --name my-eks-cluster \
  --region ap-south-1 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

> This takes ~15 minutes. It creates:
> - EKS control plane
> - EC2 worker nodes (like ECS container instances)
> - Auto-configures kubeconfig

### 2. Deploy the app

```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Verify

```bash
# List pods (like ECS tasks)
kubectl get pods

# List services (like ECS services)
kubectl get services

# View logs (like ECS logs in CloudWatch)
kubectl logs -l app=node-app --tail=50

# Describe a pod
kubectl describe pod <pod-name>
```

### 4. Access the app

```bash
# Get the LoadBalancer DNS
kubectl get service node-app-service
# Copy the EXTERNAL-IP and open in browser: http://<EXTERNAL-IP>
```

---

## Key kubectl commands (your daily drivers)

```bash
kubectl get pods                          # list pods
kubectl get deployments                   # list deployments
kubectl get services                      # list services
kubectl logs <pod-name>                   # pod logs
kubectl exec -it <pod-name> -- sh        # shell into pod (like ECS exec)
kubectl scale deployment node-app --replicas=3   # manual scale
kubectl rollout restart deployment/node-app      # rolling restart
kubectl delete deployment node-app               # teardown
```

---

## Cleanup (avoid AWS charges)

```bash
kubectl delete -f k8s/
eksctl delete cluster --name my-eks-cluster --region ap-south-1
```
