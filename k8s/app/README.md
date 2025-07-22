# 📦 App

This directory contains manifests related to deploying the Immich application stack in a Kubernetes cluster.

## Files

| File                     | Description                                  |
|--------------------------|----------------------------------------------|
| `immich-configmap.yml`   | Application configuration (ENVs). |
| `immich-lb.yml`          | LoadBalancer service to expose Immich externally. |
| `immich-ml.yml`          | Machine Learning service and deployment.     |
| `immich-redis.yml`       | Redis service and deployment.                |
| `immich-sealed-secret.yml` | Encrypted Kubernetes secret (SealedSecret). |
| `immich-secret-example.yml` | Plain Secret template for manual encryption. |
| `immich-server.yml`      | Main Immich service and deployment.       |

## 🔐 Sealed Secrets

To safely store secrets in version control, the [`Sealed Secrets`](https://github.com/bitnami-labs/sealed-secrets) controller is used.

To generate a sealed secret:

```bash
kubeseal --controller-namespace kube-system --format yaml < immich-secret.yml > immich-sealed-secret.yml