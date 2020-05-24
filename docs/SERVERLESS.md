# OpenShift Serverless - Knative
<!-- TOC -->

- [OpenShift Serverless - Knative](#openshift-serverless---knative)
  - [Knative Service](#knative-service)
  - [Revision](#revision)
  - [Route](#route)
  - [Traffic Management](#traffic-management)

<!-- /TOC -->

## Knative Service
- Create service with kn CLI
```bash
kn service create backend --namespace demo2 --image quay.io/voravitl/backend-native:v1
#Specified revision name
kn service create backend --namespace demo2 --revision-name=backend-v1 --image quay.io/voravitl/backend-native:v1
#Output
Creating service 'backend' in namespace 'demo2':

  0.228s The Route is still working to reflect the latest desired specification.
  0.321s Configuration "backend" is waiting for a Revision to become ready.
 34.327s ...
 34.419s Ingress has not yet been reconciled.
 34.510s Ready to serve.

Service 'backend' created to latest revision 'backend-rpbcx-1' is available at URL:
http://backend-demo2.apps.cluster-bkk17-d5a2.bkk17-d5a2.example.opentlc.com
```
- Create service with YAML
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: backend
spec:
  template:
    metadata:
      name: backend-v1
    spec:
      containers:
        - image: quay.io/voravit/backend:v1
          livenessProbe:
            httpGet:
              path: /healthz
          readinessProbe:
            httpGet:
              path: /healthz
```
- List service
```bash
kn service list --namespace demo2
#Output
NAME      URL                                                                           LATEST            AGE   CONDITIONS   READY   REASON
backend   http://backend-demo2.apps.cluster-bkk17-d5a2.bkk17-d5a2.example.opentlc.com   backend-rpbcx-1   73s   3 OK / 3     True
```
- Update
```bash
kn service update backend --env "APP_MESSAGE=Hola, "
kn service update backend --revision-name=backend-v2 --env "APP_MESSAGE=Hola Mundo"
kn service update backend --revision-name=backend-v2 --env "APP_MESSAGE=Hola Mundo" --image quay.io/voravitl/backend-native:v2
#Output
```
- Describe service
```bash
kn service describe backend
#Output
Name:       backend
Namespace:  demo2
Age:        3m
URL:        http://backend-demo2.apps.cluster-bkk17-d5a2.bkk17-d5a2.example.opentlc.com

Revisions:
  100%  @latest (backend-bnlvt-2) [2] (1m)
        Image:  quay.io/voravitl/backend-native:v1 (pinned to 2723fc)

Conditions:
  OK TYPE                   AGE REASON
  ++ Ready                  58s
  ++ ConfigurationsReady    59s
  ++ RoutesReady            58s
```
- Delete
```bash
kn service delete backend
```

## Revision
- list revision
```bash
kn revision list
#Output
NAME              SERVICE   TRAFFIC   TAGS   GENERATION   AGE     CONDITIONS   READY   REASON
backend-bnlvt-2   backend   100%             2            117s    3 OK / 4     True
backend-rpbcx-1   backend                    1            4m28s   3 OK / 4     True ```
- Describe revision
```bash
kn revision describe backend-rpbcx-1

# Output
Name:       backend-rpbcx-1
Namespace:  demo2
Age:        8m
Image:      quay.io/voravitl/backend-native:v1 (pinned to 2723fc)
Service:    backend

Conditions:
  OK TYPE                  AGE REASON
  ++ Ready                  8m
  ++ ContainerHealthy       8m
  ++ ResourcesAvailable     8m
   I Active                 7m NoTraffic
```
- Delete revision
```bash
kn revision delete backend-bnlvt-2

# Output
Revision 'backend-bnlvt-2' deleted in namespace 'demo2'.
```
## Route
- List route
```bash
kn route list

# Output
NAME      URL                                                                           READY
backend   http://backend-demo2.apps.cluster-bkk17-d5a2.bkk17-d5a2.example.opentlc.com   True
```
## Traffic Management
- Knative Service YAML with traffic section
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: backend
spec:
  template:
    metadata:
      name: backend-v2
    spec:
      containerConcurrency: 0
      containers:
      - env:
        - name: APP_MESSAGE
          value: Hola Mundo
        image: quay.io/voravitl/backend-native:v2
        name: user-container
        readinessProbe:
          successThreshold: 1
          tcpSocket:
            port: 0
        resources: {}
      timeoutSeconds: 300
  traffic:
  - revisionName: backend-v1
    tag: v1
    percent: 100
  - revisionName: backend-v2
    tag: v2
    percent: 0

```

