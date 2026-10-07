# VISA Kubernetes Controller Helm Chart

A production-ready Helm chart for deploying the [VISA Kubernetes Cloud Provider Controller](https://github.com/ALBA-Synchrotron/visa-k8s-controller).

The controller manages and reconciles custom resources under the `cloudprovider.visa.k8s` API group (VISA instances, cloud devices, flavours, images, security groups, and sidecar configs) within Kubernetes.

## Prerequisites

* Kubernetes 1.26+
* Helm 3.8.0+

## Installing the Chart

### 1. Install the Chart

To install the chart with the release name `visa-k8s-controller`:

```bash
helm repo add alba-synchrotron https://alba-synchrotron.github.io/visa-k8s-controller-helm
helm repo update
helm install visa-k8s-controller alba-synchrotron/visa-k8s-controller --namespace visa-system --create-namespace
```

Or from local sources:

```bash
helm install visa-k8s-controller . --namespace visa-system --create-namespace
```

### 2. Verify Installation

```bash
kubectl get pods -n visa-system -l app.kubernetes.io/name=visa-k8s-controller
```

## Configuration Parameters

The following table lists the configurable parameters of the chart and their default values:

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of controller replicas | `1` |
| `image.repository` | Controller container image repository | `misalbasynchrotron/visa-k8s` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Controller image tag | `latest` |
| `imagePullSecrets` | Secrets for pulling the controller image | `[]` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full release name | `""` |
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `serviceAccount.automount` | Automount ServiceAccount API credentials | `true` |
| `serviceAccount.annotations` | Annotations for the ServiceAccount | `{}` |
| `serviceAccount.name` | Explicit ServiceAccount name | `""` |
| `rbac.create` | Create RBAC roles and bindings for the controller | `true` |
| `rbac.createAdminRoles` | Create cluster-admin helper roles for VISA CRDs | `true` |
| `operatorScopeNamespace` | Restrict watch to namespace(s) (comma-separated). Cluster-wide if empty | `""` |
| `managedImagePullSecrets` | Comma-separated image pull secret names injected into managed VISA instances | `""` |
| `leaderElection.enabled` | Enable leader election (recommended for HA deployments) | `true` |
| `healthProbes.bindAddress` | Bind address for health probe endpoint | `":8081"` |
| `healthProbes.port` | Port number for health probe endpoint | `8081` |
| `metrics.enabled` | Enable Prometheus metrics endpoint | `true` |
| `metrics.bindAddress` | Metrics bind address (set to `"0"` to disable) | `":8443"` |
| `metrics.port` | Metrics port | `8443` |
| `metrics.secure` | Serve metrics securely via HTTPS with authn/authz filter | `true` |
| `metrics.certPath` | Path to TLS certs for metrics server | `""` |
| `metrics.certName` | Metrics TLS certificate file name | `"tls.crt"` |
| `metrics.certKey` | Metrics TLS key file name | `"tls.key"` |
| `webhook.certPath` | Path to webhook TLS certificate directory | `""` |
| `webhook.certName` | Webhook TLS certificate file name | `"tls.crt"` |
| `webhook.certKey` | Webhook TLS key file name | `"tls.key"` |
| `enableHttp2` | Enable HTTP/2 for metrics/webhook servers | `false` |
| `extraArgs` | Additional command-line flags for the controller manager | `[]` |
| `env` | Additional environment variables | `[]` |
| `envFrom` | Additional environment variables from configmaps/secrets | `[]` |
| `podAnnotations` | Annotations to add to controller pods | `{}` |
| `podLabels` | Labels to add to controller pods | `{}` |
| `podSecurityContext` | Pod security context (Restricted PSS standard) | `runAsNonRoot: true, seccompProfile: { type: RuntimeDefault }` |
| `securityContext` | Container security context | `allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, drop: [ALL]` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port for metrics | `8443` |
| `service.targetPort` | Target port for metrics service | `8443` |
| `service.healthPort` | Service port for health checks | `8081` |
| `service.annotations` | Annotations for the Service | `{}` |
| `resources.limits` | Container CPU and Memory resource limits | `cpu: 500m, memory: 256Mi` |
| `resources.requests` | Container CPU and Memory resource requests | `cpu: 50m, memory: 64Mi` |
| `livenessProbe` | Liveness probe settings | `/healthz` on port 8081 |
| `readinessProbe` | Readiness probe settings | `/readyz` on port 8081 |
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget for the controller | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available replicas during disruptions | `1` |
| `volumes` | Additional volumes to mount into the controller pod | `[]` |
| `volumeMounts` | Additional volume mounts for the controller container | `[]` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Toleration labels for pod assignment | `[]` |
| `affinity` | Affinity rules for pod assignment | `{}` |

## Operational Guidance

### High Availability (HA)

To run the controller in High Availability mode:

```yaml
replicaCount: 2
leaderElection:
  enabled: true
podDisruptionBudget:
  enabled: true
  minAvailable: 1
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - visa-k8s-controller
          topologyKey: kubernetes.io/hostname
```

### Metrics & Monitoring

By default, Prometheus metrics are enabled and served securely over HTTPS on port 8443.

```yaml
metrics:
  enabled: true
  secure: true
  port: 8443
```

To access the metrics endpoint locally:

```bash
# Port-forward the metrics service
kubectl port-forward -n visa-system svc/visa-k8s-controller 8443:8443

# Query metrics with a bearer token from the ServiceAccount
curl -k https://127.0.0.1:8443/metrics \
  -H "Authorization: Bearer $(kubectl create token visa-k8s-controller -n visa-system)"
```

## License

Copyright (C) 2026 ALBA Synchrotron

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
