# 🗄️ PostgreSQL 

This directory contains manifests for deploying the PostgreSQL database used by Immich.

## Files

- `immich-database-service.yml` — internal ClusterIP service exposing the PostgreSQL pod.
- `postgres-statefulset.yml` — StatefulSet for a single persistent PostgreSQL instance using RWO volume.

## 📦 Storage

PostgreSQL stores data on a PersistentVolumeClaim backed by Linode Block Storage.

## ⚠️ Notes

- Only one replica is used because the volume access mode is ReadWriteOnce.
- Database credentials and name are provided via environment variables.
- DB_PASSWORD value come from the sealed secret defined in `../app/immich-sealed-secret.yml`.