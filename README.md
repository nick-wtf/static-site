# Static Site Helm Chart

This Helm chart deploys a static website using Nginx on Kubernetes with persistent storage.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-static-site`:

```console
$ helm install my-static-site ./static-site
```

## Uninstalling the Chart

To uninstall/delete the `my-static-site` deployment:

```console
$ helm delete my-static-site
```

## Parameters

| Parameter                 | Description                                       | Default                 |
|---------------------------|---------------------------------------------------|-------------------------|
| `replicaCount`            | Number of replicas                                | `1`                     |
| `image.repository`        | Image repository                                  | `nginx`                 |
| `image.tag`               | Image tag                                         | `stable`                |
| `image.pullPolicy`        | Image pull policy                                 | `IfNotPresent`          |
| `service.type`            | Service type                                      | `ClusterIP`             |
| `service.port`            | Service port                                      | `80`                    |
| `ingress.enabled`         | Enable ingress controller resource                | `false`                 |
| `ingress.annotations`     | Ingress annotations                               | `{}`                    |
| `ingress.hosts[0].host`   | Hostname to your static site                      | `chart-example.local`   |
| `ingress.hosts[0].paths`  | Path within the url structure                     | `["/"]`                 |
| `ingress.tls`             | TLS configuration                                 | `[]`                    |
| `resources`               | CPU/Memory resource requests/limits               | `{}`                    |
| `persistence.enabled`     | Enable persistence                               | `true`                  |
| `persistence.type`        | Type of persistence (pvc or hostPath)            | `pvc`                   |
| `persistence.storageClass`| StorageClass for PVC (when type=pvc)            | `""`                    |
| `persistence.accessMode`  | Access mode for PVC (when type=pvc)             | `ReadWriteOnce`         |
| `persistence.size`        | Size of PVC (when type=pvc)                     | `1Gi`                   |
| `persistence.hostPath`    | Path on host to use (when type=hostPath)         | `""`                    |
| `nodeSelector`            | Node labels for pod assignment                    | `{}`                    |
| `tolerations`             | List of node taints to tolerate                   | `[]`                    |
| `affinity`                | Node affinity for pod assignment                  | `{}`                    |

## Adding Your Own Static Content

### Using PVC (persistence.type=pvc)

When using a PVC for persistence, you'll need to copy your static files to the persistent volume:

1. Deploy the chart
2. Create a temporary pod that mounts the same PVC
3. Copy your files to the volume

Example:

```bash
# Deploy chart
helm install my-static-site ./static-site

# Create temporary pod to copy files
kubectl run temp-copy --image=busybox --rm -i --tty --volumes-from=$(kubectl get pods -l app.kubernetes.io/name=static-site -o jsonpath='{.items[0].metadata.name}')

# Inside the temporary pod, copy your files
cp -R /your/files/* /usr/share/nginx/html/

# Exit the pod
exit
```

### Using Host Path (persistence.type=hostPath)

When using a host path, you can place your static files directly in the specified directory on the host machine:

```bash
# Create directory on host (if it doesn't exist)
mkdir -p /path/to/your/website

# Copy your static files to that directory
cp -R /your/website/files/* /path/to/your/website/

# Deploy chart specifying the host path
helm install my-static-site ./static-site --set persistence.type=hostPath --set persistence.hostPath=/path/to/your/website
```

Note: Using hostPath requires that the directory exists on all nodes where the pod might be scheduled, or you must use node selectors to ensure the pod runs on the correct node.

Alternatively, you can use an initContainer in the deployment to pull content from a git repository or other source.