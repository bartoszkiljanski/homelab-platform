# Authentik Application Blueprints

Keep shared groups in `groups-blueprint.yaml` and give each integrated
application its own `<app>-blueprint.yaml`. Native OIDC applications define an
OAuth2 provider; applications without native authentication use a proxy
provider with `mode: proxy`.

To add another proxy-protected application:

1. Add `<app>-blueprint.yaml` containing its proxy provider, application, and
   group policy bindings.
2. Register its ConfigMap in both `kustomization.yaml` and
   `blueprints.configMaps` in `values.yaml`.
3. Add the provider to the authoritative list in
   `proxy-outpost-blueprint.yaml`, and add a `metaapplyblueprint` dependency for
   the application blueprint above the outpost entry.
4. Route the application's external hostname to `authentik-server` and add a
   `ReferenceGrant` permitting that application's namespace to reference the
   service.
5. Point the provider's `internal_host` at the application's ClusterIP service,
   for example `http://my-app.my-app.svc.cluster.local:8080`.

Do not create a separate embedded-outpost entry in each application blueprint:
the `providers` attribute is replaced as a complete list during reconciliation.
