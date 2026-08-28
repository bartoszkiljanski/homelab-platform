# Servarr

This application deploys Jellyfin, Sonarr, Radarr, Lidarr, Bazarr, Prowlarr,
FlareSolverr, Seerr, and Cleanuparr. qBittorrent is intentionally disabled in
this chart and deployed by `apps/qbittorrent-vpn` together with Gluetun and
Proton VPN WireGuard.

## Storage and databases

Application configuration uses dynamically provisioned, retained Synology NFS
volumes. Media uses the manually managed `servarr-media` claim. Its persistent
volume and claim are protected from Argo CD pruning.

Sonarr, Radarr, Lidarr, and Cleanuparr use the shared CloudNativePG cluster.
Their passwords are supplied by External Secrets. Jellyfin, Prowlarr, Bazarr,
and Seerr retain application-local databases on their NFS configuration
volumes, so PostgreSQL recovery alone is not a complete stack backup.

The shared media layout is:

- Sonarr library: `/data/media/tv`
- Radarr library: `/data/media/movies`
- Lidarr library: `/data/media/music`
- qBittorrent categories: `/data/torrents/tv`,
  `/data/torrents/movies`, and `/data/torrents/music`

All download and library paths remain below `/data` on one filesystem. Arr can
therefore import completed torrents with hardlinks instead of storing a second
copy. Remote path mappings are not required.

## Access and authentication

Gateway API routes expose the configured applications on the LAN gateway.
Authentik proxy authentication protects the Arr administration interfaces;
their native authentication is set to external where supported. Jellyfin keeps
native authentication for compatibility with television and mobile clients.

## Jellyfin transcoding

Jellyfin currently uses software transcoding. The Talos virtual machines do not
have a `/dev/dri` device, so hardware acceleration must remain disabled until a
GPU or iGPU is passed through by Proxmox and exposed to the Jellyfin pod.
