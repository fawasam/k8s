5 pods running in under 20 seconds. Watch what you saw happen step by step:

ContainerCreating → Running (0/1) → Running (1/1)
↑ ↑ ↑
pulling image container up readiness probe passed
(now gets traffic)
Scale back down to 2
kubectl scale deployment node-app --replicas=2
K8s will gracefully terminate 3 pods and keep 2. Try it yourself in your terminal — it's the same command you just saw work.

Key insight — scale vs ECS

| ECS          | Kubernetes                   |
| ------------ | ---------------------------- | ---------------------------- |
| Manual scale | Update service desired count | `kubectl scale deployment`   |
| Auto scale   | ECS Service Auto Scaling     | HPA (already set up for you) |
| Speed        | ~30-60s                      | ~5-15s                       |

Your HPA is already watching CPU — if traffic spikes above 70% CPU it will scale automatically from 2 up to 10 without you doing anything.




kubectl scale deployment node-app --replicas=2