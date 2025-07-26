# Immich Helm Chart

This is a Helm chart to deploy [Immich](https://github.com/immich-app/immich) — a self-hosted photo and video backup solution — into a Kubernetes cluster.

---

## Prerequisites

Before installing this chart, ensure the following are already configured in your cluster:

- A functioning NFS server inside the cluster.
- NFS CSI driver and Sealed Secrets controller are installed.
- A valid Sealed Secret has been generated using the cluster’s public key.
- The namespace to deploy the app must already exist.

You can find instructions for installing these controllers in their official documentation.

---

## Create Namespace

```bash
kubectl create namespace immich
```

## Apply Sealed Secret (pre-generated)

```bash
kubectl apply -f immich-sealed-secret.yaml -n immich
```
## Install the Chart

```bash
helm install immich ./immich-0.1.0.tgz -n immich
```
## Notes
This chart does not include Namespace creation logic — the namespace must exist before installation.

You are encouraged to customize values.yaml to match your infrastructure setup.

The sealed-secrets resource is not included in the Helm release and must be applied manually before installation.