# Servarr

This application deploys Jellyfin, Sonarr, Radarr, Lidarr, Bazarr, Prowlarr,
FlareSolverr, Seerr, and Cleanuparr. qBittorrent remains disabled until it can
share a pod network namespace with a configured Gluetun WireGuard container.

## Storage

Application configuration uses dynamically provisioned, retained NFS volumes.
Media uses the manually managed `servarr-media` claim backed by the Synology
NFS export at `/volume1/media`. The persistent volume and claim are protected
from Argo CD pruning. The cluster-scoped volume is owned by the `nfs-csi`
infrastructure application; this application owns its namespaced claim.

Configure each application with these paths:

- Sonarr root: `/data/media/tv`
- Radarr root: `/data/media/movies`
- Lidarr root: `/data/media/music`
- Jellyfin libraries: the corresponding directories under `/data/media`
- Future qBittorrent categories: `/data/torrents/tv`,
  `/data/torrents/movies`, and `/data/torrents/music`

Keeping downloads and libraries beneath `/data` allows atomic moves and
hardlinks because they remain on one filesystem.

The Arr configuration volumes currently contain SQLite databases. Initial
schema migrations can therefore be slow over NFS. Moving Sonarr, Radarr, and
Lidarr to the platform PostgreSQL cluster is intentionally deferred until the
applications are configured and their databases can be migrated with a tested
rollback path.

## Initial access

Ingress is intentionally disabled during the initial setup. Reach a service
with `kubectl port-forward`, for example:

```console
kubectl -n servarr port-forward service/servarr-jellyfin 8096:8096
```
