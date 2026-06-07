v5.0.0 live with ConfigMap & Secret working! Look at the response:

appEnv: "production" ← came from ConfigMap
dbHost: "postgres.internal..." ← came from ConfigMap
dbUser: "appuser" ← came from Secret
hasDbPassword: true ← Secret exists but we never expose the actual value ✅
Useful kubectl commands for ConfigMap & Secret

# View ConfigMap

kubectl get configmap node-app-config -o yaml

# Edit ConfigMap live (pods pick it up automatically)

kubectl edit configmap node-app-config

# View Secret (values are base64 encoded)

kubectl get secret node-app-secret -o yaml

# Decode a secret value

kubectl get secret node-app-secret \
 -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode

# List all configmaps and secrets

kubectl get configmaps
kubectl get secrets



Ran
Show ConfigMap and decode Secret


Let's verify the secret decode works:
Everything working perfectly. Here's the full picture:

Summary — ConfigMap vs Secret

| configmap.yaml          | secret.yaml           |
| ----------------------- | --------------------- |
| APP_ENV=production      | DB_USER=appuser       |
| DB_HOST=postgres...     | DB_PASSWORD=\*\*\* |
| ↓                       | ↓                     |

| deployment.yaml         |                       |
| envFrom ConfigMap → injected into pod | |  
| envFrom Secret → injected into pod ||
↓



Your Node app
process.env.APP_ENV
process.env.DB_PASSWORD






⚠️ Real-world rule

| Dev/Learning | Production |
| ------------ | ---------- |
| ConfigMap ✅ | ✅ commit to git | 
| Secret yaml ✅ | ❌ NEVER commit — use AWS Secrets Manager or Sealed Secrets |



How it all connects
AWS SSM Parameter Store
  /node-app/prod/DB_USER      = "appuser"
  /node-app/prod/DB_PASSWORD  = "supersecret123"
  /node-app/prod/API_KEY      = "my-api-key"
         ↓  (synced every 1 hour)
External Secrets Operator
  ClusterSecretStore → connects to SSM with AWS creds
  ExternalSecret     → maps SSM paths → K8s Secret keys
         ↓  (auto-created)
K8s Secret: node-app-secret
  DB_USER     = appuser
  DB_PASSWORD = supersecret123
         ↓  (injected as env vars)
Your Pod
  process.env.DB_USER     ✅
  process.env.DB_PASSWORD ✅
Update a secret — no redeploy needed
# 1. Update in SSM
aws ssm put-parameter \
  --name "/node-app/prod/DB_PASSWORD" \
  --value "newpassword456" \
  --type SecureString \
  --overwrite \
  --region ap-south-1

# 2. Force immediate sync (or wait 1 hour)
kubectl annotate externalsecret node-app-secret \
  force-sync=$(date +%s) --overwrite

# 3. Restart pods to pick up new value
kubectl rollout restart deployment/node-app