# 🚀 Deployment Guide - Production & Advanced Configurations

## 📋 Production Deployment Options

### Option 1: Cloud Kubernetes Services

#### Azure Kubernetes Service (AKS)
```bash
# Install Azure CLI
az login
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 3 --enable-addons monitoring --generate-ssh-keys
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

#### Amazon EKS
```bash
# Install eksctl
eksctl create cluster --name my-cluster --region us-west-2 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4
```

#### Google GKE
```bash
# Install gcloud CLI
gcloud container clusters create my-cluster --zone us-central1-a --num-nodes 3
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

### Option 2: Self-Hosted Kubernetes
```bash
# Using kubeadm
kubeadm init --pod-network-cidr=10.244.0.0/16
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

## 🔐 Security Configurations

### 1. Secrets Management
Replace the simple secrets with proper secret management:

```yaml
# k8s-manifests/secrets.yaml (Production)
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: cloud-native-app
type: Opaque
data:
  POSTGRES_PASSWORD: <base64-encoded-strong-password>
  POSTGRES_USER: <base64-encoded-user>
  POSTGRES_DB: <base64-encoded-db-name>
  JWT_SECRET: <base64-encoded-jwt-secret>
```

### 2. Network Policies
```yaml
# k8s-manifests/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: cloud-native-app
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5000
```

### 3. RBAC Configuration
```yaml
# k8s-manifests/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: cloud-native-app
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: cloud-native-app
  name: app-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-role-binding
  namespace: cloud-native-app
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: cloud-native-app
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
```

## 📊 Monitoring & Observability

### 1. Prometheus & Grafana Setup
```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Install Prometheus Stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.enabled=true
```

### 2. Application Metrics
Add metrics endpoints to the backend:

```python
# backend/app.py (add to existing file)
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

# Metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency')

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    REQUEST_COUNT.labels(method=request.method, endpoint=request.endpoint).inc()
    REQUEST_LATENCY.observe(time.time() - request.start_time)
    return response
```

### 3. Service Mesh (Istio)
```bash
# Install Istio
istioctl install --set profile=demo -y

# Enable automatic sidecar injection
kubectl label namespace cloud-native-app istio-injection=enabled

# Apply Istio resources
kubectl apply -f istio/
```

## 🔄 CI/CD Pipeline Enhancements

### 1. Advanced GitHub Actions
```yaml
# .github/workflows/advanced-ci-cd.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  performance-test:
    runs-on: ubuntu-latest
    needs: deploy
    steps:
    - name: Run performance tests
      run: |
        # Add your performance testing commands here
        echo "Running performance tests..."
```

### 2. Blue-Green Deployment
```yaml
# k8s-manifests/blue-green-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: frontend-rollout
  namespace: cloud-native-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: yourusername/frontend-app:latest
  strategy:
    blueGreen:
      activeService: frontend-service-active
      previewService: frontend-service-preview
      autoPromotionEnabled: false
```

## 🚀 Scaling Configurations

### 1. Horizontal Pod Autoscaler
```yaml
# k8s-manifests/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
  namespace: cloud-native-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 2. Vertical Pod Autoscaler
```yaml
# k8s-manifests/vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: backend-vpa
  namespace: cloud-native-app
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
  updatePolicy:
    updateMode: "Auto"
```

## 🗄️ Database Configurations

### 1. PostgreSQL with Persistent Storage
```yaml
# k8s-manifests/postgres-persistent.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: cloud-native-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-statefulset
  namespace: cloud-native-app
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: POSTGRES_PASSWORD
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### 2. Database Backup Strategy
```yaml
# k8s-manifests/backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: db-backup
  namespace: cloud-native-app
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:13
            command:
            - /bin/bash
            - -c
            - |
              pg_dump -h postgres-service -U postgres -d cloudapp > /backup/backup-$(date +%Y%m%d).sql
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: POSTGRES_PASSWORD
            volumeMounts:
            - name: backup-volume
              mountPath: /backup
          volumes:
          - name: backup-volume
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

## 🔍 Logging & Tracing

### 1. Centralized Logging (ELK Stack)
```yaml
# k8s-manifests/logging.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: cloud-native-app
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch-service
      port 9200
      logstash_format true
      logstash_prefix k8s
    </match>
```

### 2. Distributed Tracing (Jaeger)
```bash
# Install Jaeger
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
```

## 📈 Performance Optimization

### 1. Resource Limits & Requests
```yaml
# Example resource configuration
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### 2. Pod Disruption Budget
```yaml
# k8s-manifests/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-pdb
  namespace: cloud-native-app
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: frontend
```

## 🚨 Disaster Recovery

### 1. Backup Strategy
```bash
# Database backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
kubectl exec -n cloud-native-app deployment/postgres-deployment -- pg_dump -U postgres cloudapp > backup_$DATE.sql
```

### 2. Multi-Region Deployment
```yaml
# k8s-manifests/multi-region.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: multi-region-config
  namespace: cloud-native-app
data:
  regions: |
    - name: us-east-1
      endpoint: https://us-east-1.example.com
    - name: us-west-2
      endpoint: https://us-west-2.example.com
```

## 📋 Deployment Checklist

- [ ] Update Docker image names with your username
- [ ] Configure secrets with strong passwords
- [ ] Set up monitoring and logging
- [ ] Configure resource limits
- [ ] Set up backup strategy
- [ ] Test disaster recovery procedures
- [ ] Configure network policies
- [ ] Set up RBAC
- [ ] Configure ingress with SSL
- [ ] Set up CI/CD pipeline
- [ ] Configure autoscaling
- [ ] Test performance under load
- [ ] Document runbooks and procedures 