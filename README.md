## About This Project

This repository documents my personal journey in learning and applying DevOps practices, methodologies, and toolkit through a practical, evolving project.

The ultimate goal is to demonstrate the integration of CI/CD processes, Infrastructure as Code (IaC), cloud infrastructure, and monitoring, metric collection, and analysis — all added progressively as I advance in my skills.

> ⚠️ This is not a production-ready or reference implementation. It may contain mistakes or suboptimal decisions, which I intend to revisit and improve over time.

To support this learning process, I’ve chosen to deploy [Immich](https://github.com/immich-app/immich) — a high-performance, self-hosted solution for managing personal photo and video libraries.

Many thanks to the Immich team for their work on this great application.

## 🛠️ Current State

At this stage, the Immich application has been successfully deployed to a Kubernetes cluster running in Linode Kubernetes Engine (LKE).  
The app is publicly accessible via an external LoadBalancer.

Some intended features are not yet functioning as expected and will be revisited after migrating the application to a more robust cloud environment (e.g. AWS)

More technical details can be found in the [k8s/](./k8s) directory and in the DEVLOG (to be published soon).

## 📌 Near-term plans

This section outlines the key objectives I plan to tackle next as I continue improving the project:

- **Fix RWX (ReadWriteMany) support.**  
  The current setup includes an in-cluster NFS server configured for RWX access. However, the implementation is non-functional at the moment, and media storage currently falls back to node-local storage. The RWX issue will not be resolved in the current cluster — instead, I plan to address it properly once the project moves to an AWS-based production-ready setup.

- **Introduce Helm charts.**  
  I plan to replace the current static Kubernetes manifests with reusable and configurable Helm charts to simplify deployment and configuration management.

- **Refactor and improve the current setup.**  
  I aim to revisit and fix suboptimal decisions, reorganize Kubernetes manifests, and improve structure, naming, and reliability across all project components.

These tasks represent the immediate next steps in the ongoing development of this project.
