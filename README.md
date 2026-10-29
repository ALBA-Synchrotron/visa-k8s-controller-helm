# VISA Kubernetes Controller & Web Cloud Provider Helm Chart

A production-ready Helm chart for deploying the [VISA Kubernetes Cloud Provider Controller](https://github.com/ALBA-Synchrotron/visa-k8s-controller) and the [VISA Cloud Web Provider Kubernetes](https://github.com/ALBA-Synchrotron/visa-cloud-web-provider-kubernetes).

* **Controller**: Manages and reconciles custom resources under the `cloudprovider.visa.k8s` API group (VISA instances, cloud devices, flavours, images, security groups, and sidecar configs) within Kubernetes.
* **Web Cloud Provider**: A REST API service implementing the cloud provider backend for the VISA platform on top of Kubernetes, translating VISA API operations into custom resources.

The controller and web cloud provider can be deployed together or independently using `controller.enabled` and `webCloudProvider.enabled`.

## Prerequisites

* Kubernetes 1.26+
* Helm 3.8.0+

## Installing the Chart

### 1. Install the Chart

To install both the controller and the web cloud provider with the release name `visa-k8s`:

```bash
helm repo add alba-synchrotron https://alba-synchrotron.github.io/visa-k8s-controller-helm
helm repo update
helm install visa-k8s alba-synchrotron/visa-k8s-controller --namespace visa-system --create-namespace
```

Or from local sources:

```bash
helm install visa-k8s . --namespace visa-system --create-namespace
```

#### Deploying Components Independently

To deploy only the Controller:
```bash
helm install visa-k8s . --namespace visa-system --create-namespace \
  --set controller.enabled=true \
  --set webCloudProvider.enabled=false
```

To deploy only the Web Cloud Provider:
```bash
helm install visa-k8s . --namespace visa-system --create-namespace \
  --set controller.enabled=false \
  --set webCloudProvider.enabled=true
```

### 2. Verify Installation

```bash
kubectl get pods -n visa-system
```

### 3. Retrieve Web Cloud Provider API Key

The Web Cloud Provider configuration and generated `AUTH_API_KEY` are stored in a ConfigMap. To retrieve the generated API key:

```bash
kubectl get configmap visa-k8s-web-cloud-provider-config -n visa-system -o jsonpath="{.data.AUTH_API_KEY}"
```

## Configuration Parameters

### Controller Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| `controller.enabled` | Enable or disable the controller deployment | `true` |
| `crds.install` | Install VISA Custom Resource Definitions (only if `controller.enabled=true`) | `true` |
| `replicaCount` | Number of controller replicas | `1` |
| `image.repository` | Controller container image repository | `misalbasynchrotron/visa-k8s-controller` |
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

### Web Cloud Provider Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| `webCloudProvider.enabled` | Enable or disable the Web Cloud Provider deployment | `true` |
| `webCloudProvider.replicaCount` | Number of web cloud provider replicas | `1` |
| `webCloudProvider.image.repository` | Web cloud provider container image repository | `misalbasynchrotron/visa-k8s-web-cloud-provider` |
| `webCloudProvider.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `webCloudProvider.image.tag` | Image tag | `latest` |
| `webCloudProvider.imagePullSecrets` | Secrets for pulling the web cloud provider image | `[]` |
| `webCloudProvider.nameOverride` | Override name for web cloud provider | `""` |
| `webCloudProvider.fullnameOverride` | Override full release name for web cloud provider | `""` |
| `webCloudProvider.serviceAccount.create` | Create a ServiceAccount for web cloud provider | `true` |
| `webCloudProvider.serviceAccount.automount` | Automount ServiceAccount API credentials | `true` |
| `webCloudProvider.serviceAccount.annotations` | Annotations for the ServiceAccount | `{}` |
| `webCloudProvider.serviceAccount.name` | Explicit ServiceAccount name | `""` |
| `webCloudProvider.rbac.create` | Create RBAC Role and RoleBinding for web cloud provider | `true` |
| `webCloudProvider.rbac.clusterScoped` | Create ClusterRole instead of namespaced Role | `false` |
| `webCloudProvider.config.authApiKey` | Secret API key (auto-generated 32-char string if empty) | `""` |
| `webCloudProvider.config.authApiKeyHeaderName` | HTTP header name for API authentication token | `"X-Auth-Token"` |
| `webCloudProvider.config.flaskEnv` | Flask environment profile (`prod`, `dev`, `test`) | `"prod"` |
| `webCloudProvider.config.testingMode` | Testing profile mode (`unit`, `integration`) | `"unit"` |
| `webCloudProvider.config.k8sConfigSource` | Kubernetes client config mode (`serviceaccount`, `kubeconfig`) | `"serviceaccount"` |
| `webCloudProvider.config.k8sConfigFilePath` | Path to kubeconfig file when using `kubeconfig` mode | `"~/.kube/config"` |
| `webCloudProvider.config.k8sNamespace` | Target Kubernetes namespace where VISA CRD instances reside (defaults to release namespace) | `""` |
| `webCloudProvider.config.logLevel` | Python logging level (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`) | `"INFO"` |
| `webCloudProvider.config.apiHost` | Host address to bind HTTP server | `"0.0.0.0"` |
| `webCloudProvider.config.apiPort` | Port number to bind HTTP server | `8000` |
| `webCloudProvider.config.port` | Port for container runtime | `8000` |
| `webCloudProvider.config.autoStartInstancesOnCreation` | Automatically set desiredState to ACTIVE when creating instances | `true` |
| `webCloudProvider.config.maxRamAllocated` | Maximum aggregate RAM quota in MB across all instances | `51200` (50 GB) |
| `webCloudProvider.config.maxInstancesAllocated` | Maximum number of simultaneously running instances quota | `20` |
| `webCloudProvider.config.maxCoresAllocated` | Maximum aggregate CPU cores quota across all instances | `15` |
| `webCloudProvider.config.ignoreSecGroupNotFoundErrors` | Ignore non-existent security groups during instance creation | `true` |
| `webCloudProvider.config.enforceMaxQuotas` | Enforce instance/CPU/RAM quota validation during instance creation | `true` |
| `webCloudProvider.config.webConcurrency` | Gunicorn worker concurrency | `2` |
| `webCloudProvider.config.gunicornThreads` | Gunicorn threads per worker | `4` |
| `webCloudProvider.config.extraConfig` | Additional key-value pairs for the ConfigMap | `{}` |
| `webCloudProvider.existingConfigMap` | Use pre-existing ConfigMap name instead of creating one | `""` |
| `webCloudProvider.forceOverwriteConfigMap` | Overwrite ConfigMap data on helm upgrade (default false preserves existing ConfigMap) | `false` |
| `webCloudProvider.configMapAnnotations` | Annotations for the ConfigMap | `{}` |
| `webCloudProvider.env` | Additional environment variables | `[]` |
| `webCloudProvider.envFrom` | Additional environment variables from configmaps/secrets | `[]` |
| `webCloudProvider.podAnnotations` | Annotations for pods | `{}` |
| `webCloudProvider.podLabels` | Labels for pods | `{}` |
| `webCloudProvider.podSecurityContext` | Pod security context | `runAsNonRoot: true, runAsUser: 1001, runAsGroup: 1001, fsGroup: 1001` |
| `webCloudProvider.securityContext` | Container security context | `allowPrivilegeEscalation: false, drop: [ALL]` |
| `webCloudProvider.service.type` | Kubernetes Service type | `ClusterIP` |
| `webCloudProvider.service.port` | Service port | `8000` |
| `webCloudProvider.service.targetPort` | Target container port | `8000` |
| `webCloudProvider.service.annotations` | Annotations for the Service | `{}` |
| `webCloudProvider.ingress.enabled` | Enable Ingress resource for web cloud provider | `false` |
| `webCloudProvider.ingress.className` | Ingress class name | `""` |
| `webCloudProvider.ingress.annotations` | Ingress annotations | `{}` |
| `webCloudProvider.ingress.hosts` | Ingress hosts configuration | `[{host: visa-web-provider.local, paths: [{path: /, pathType: Prefix}]}]` |
| `webCloudProvider.ingress.tls` | Ingress TLS configuration | `[]` |
| `webCloudProvider.resources.limits` | Container CPU and Memory resource limits | `cpu: 500m, memory: 512Mi` |
| `webCloudProvider.resources.requests` | Container CPU and Memory resource requests | `cpu: 100m, memory: 128Mi` |
| `webCloudProvider.livenessProbe` | Liveness probe settings | `/healthz` on port 8000 |
| `webCloudProvider.readinessProbe` | Readiness probe settings | `/healthz` on port 8000 |
| `webCloudProvider.podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `webCloudProvider.volumes` | Additional volumes to mount into pod | `[]` |
| `webCloudProvider.volumeMounts` | Additional volume mounts | `[]` |
| `webCloudProvider.nodeSelector` | Node labels for pod assignment | `{}` |
| `webCloudProvider.tolerations` | Tolerations for pod assignment | `[]` |
| `webCloudProvider.affinity` | Affinity rules for pod assignment | `{}` |

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
