We have 2 pods running. Now let's kill one and watch Kubernetes bring it back:


Ran 2 commands
See what happened:

BEFORE:  node-app-69b6c8d4d8-mbxd4   ← we killed this
         node-app-69b6c8d4d8-w9862
AFTER:   node-app-69b6c8d4d8-fsnrr   ← brand new pod (different name)
         node-app-69b6c8d4d8-w9862   ← untouched


Kubernetes detected replicas: 2 was violated → immediately spun up a replacement pod. The whole recovery took under 5 seconds.

Why this matters

| Scenario | What happens |
| -------- | ----------- |
| Pod crashes (OOM, bug) | K8s restarts it automatically |
| EC2 node dies | K8s reschedules pods onto healthy nodes |
| You manually delete a pod | K8s replaces it immediately |
| App fails health check | K8s kills + restarts the pod |



This is the core power of Kubernetes — self-healing. 
In ECS you had this too with service desired count, but K8s does it at a much finer granularity and faster.