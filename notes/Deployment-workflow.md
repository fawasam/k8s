# Set your version

VERSION=v4.0.0 # bump this each release: v5.0.0, v6.0.0 etc.
ECR=037049058245.dkr.ecr.ap-south-1.amazonaws.com/k8s-node-app

# 1. Login to ECR

aws ecr get-login-password --region ap-south-1 | \
 docker login --username AWS --password-stdin 037049058245.dkr.ecr.ap-south-1.amazonaws.com

# 2. Build with version tag (amd64 for EC2)

docker buildx build --platform linux/amd64 \
 -t $ECR:$VERSION --push .

# 3. Deploy to K8s

kubectl set image deployment/node-app node-app=$ECR:$VERSION

# 4. Watch rollout

kubectl rollout status deployment/node-app

# 5. Verify

curl http://a05602261b3404c8ba24dbd0a62b1332-367191808.ap-south-1.elb.amazonaws.com/
If something breaks — rollback in 1 command
kubectl rollout undo deployment/node-app

# or to a specific version:

kubectl rollout undo deployment/node-app --to-revision=10

ECR now has your full version history:

| Tag    | What's in it         |
| ------ | -------------------- |
| v3.0.0 | added ts field       |
| v4.0.0 | current live version |
