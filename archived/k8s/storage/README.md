# 📁 Storage

This directory contains manifests related to the NFS server and PersistentVolumeClaims used for shared storage.

## Files

- `nfs-server.yml` — Deployment and Service for an in-cluster NFS server.
- `nfs-pvc.yml` — PersistentVolumeClaim by the NFS server.

## ⚠️ Limitations

- RWX (ReadWriteMany) access is currently **not functional** due to restrictions in the Linode Kubernetes Engine.
- This will be addressed after migrating the cluster to AWS with a more robust and production-grade storage backend. 
