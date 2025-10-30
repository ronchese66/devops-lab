# 📂 Kubernetes Manifests for Immich

This directory contains the Kubernetes manifests used to deploy and operate the Immich application and its dependencies in a managed Kubernetes cluster (Linode Kubernetes Engine).

The configuration is designed as a foundation for a production-grade setup, with future improvements planned in the areas of fault tolerance, scalability, and secure data storage.


## 🗂️ Directory Structure

- `app/` – Deployments, Services, Ingress, ConfigMap and other manifests related to Immich microservices.
- `postgres/` – StatefulSet and Service setup for the PostgreSQL database used by Immich.
- `storage/` – NFS server configuration.
- `base/` – Namespace manifest and other.

Each subdirectory contains a separate `README.md` file describing the resources and design decisions relevant to its scope.

## ⚙️ Kubernetes Components Used

The following controllers and drivers are involved in the functioning of this cluster:

### CSI Drivers

- **`nfs.csi.k8s.io`** – Provides RWX volume support via a built-in NFS server.
- **`linodebs.csi.linode.com`** – CSI driver for provisioning Linode Block Storage volumes (RWO) for components like PostgreSQL.

### Core Controllers

- **Calico** – Provides CNI networking and network policies.
- **Calico Typha** – Optimizes scale-out of Calico in large clusters by reducing control plane load.
- **CoreDNS** – Cluster DNS service for internal name resolution.
- **kube-proxy** – Maintains networking rules on nodes for service routing.
- **Sealed Secrets Controller** – Manages encrypted secrets using Bitnami’s Sealed Secrets.
- **Ingress-NGINX Controller** – Handles HTTP routing from the internet to internal services.
- **cert-manager** (webhook & cainjector) – Manages TLS certificates using Let’s Encrypt via Kubernetes resources.

Some controllers are installed by default with LKE or helm charts, while others were added manually to support specific functionality.

---

For more details, see the `README.md` files in each subdirectory.

