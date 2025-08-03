# 🚀 Setup Guide - Cloud-Native Multi-Service App

## 📋 Prerequisites

Before starting, ensure you have the following tools installed:

### 1. Required Tools
- **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)
- **Minikube** - [Installation guide](https://minikube.sigs.k8s.io/docs/start/)
- **kubectl** - [Installation guide](https://kubernetes.io/docs/tasks/tools/)
- **Node.js** (v16+) - [Download here](https://nodejs.org/)
- **Python** (3.9+) - [Download here](https://www.python.org/downloads/)
- **Git** - [Download here](https://git-scm.com/)

### 2. Verify Installations
```bash
# Check Docker
docker --version
docker-compose --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Node.js
node --version
npm --version

# Check Python
python --version
pip --version

# Check Git
git --version
```

## 🛠️ Step-by-Step Setup

### Step 1: Clone and Navigate to Project
```bash
git clone <your-repo-url>
cd multi-service-app
```

### Step 2: Update Docker Images (IMPORTANT!)
Before building, update the Docker image names in the Kubernetes manifests:

**Files to update:**
- `k8s-manifests/frontend-deployment.yaml`
- `k8s-manifests/backend-deployment.yaml`
- `.github/workflows/ci-cd.yml`

**Replace `yourusername` with your actual Docker Hub username:**
```yaml
# Example: if your Docker Hub username is "johndoe"
image: johndoe/frontend-app:latest
image: johndoe/backend-api:latest
```

### Step 3: Build Frontend
```bash
cd frontend
npm install
npm run build
cd ..
```

### Step 4: Build and Push Docker Images
```bash
# Login to Docker Hub
docker login

# Build frontend image
docker build -t yourusername/frontend-app:latest ./frontend
docker push yourusername/frontend-app:latest

# Build backend image
docker build -t yourusername/backend-api:latest ./backend
docker push yourusername/backend-api:latest
```

### Step 5: Start Minikube
```bash
# Start Minikube with enough resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Enable ingress addon (optional)
minikube addons enable ingress

# Check status
minikube status
kubectl cluster-info
```

### Step 6: Deploy to Kubernetes
```bash
# Apply all manifests
kubectl apply -f k8s-manifests/

# Check deployments
kubectl get all -n cloud-native-app

# Check pods status
kubectl get pods -n cloud-native-app

# Check services
kubectl get services -n cloud-native-app
```

### Step 7: Access the Application
```bash
# Get Minikube IP
minikube ip

# Access frontend (NodePort 30001)
minikube service frontend-service -n cloud-native-app

# Or manually construct URL
# http://<minikube-ip>:30001
```

## 🔧 Configuration

### Environment Variables
The application uses the following environment variables:

**Backend (Flask):**
- `DB_HOST`: PostgreSQL service hostname
- `DB_PORT`: PostgreSQL port (default: 5432)
- `DB_NAME`: Database name (default: cloudapp)
- `DB_USER`: Database user (default: postgres)
- `DB_PASSWORD`: Database password

**Frontend (React):**
- `REACT_APP_API_URL`: Backend API URL (auto-configured)

### Database Configuration
The PostgreSQL database is automatically initialized with:
- Database: `cloudapp`
- User: `postgres`
- Password: `password` (change in production!)

## 🧪 Testing

### Test Frontend Locally
```bash
cd frontend
npm start
# Open http://localhost:3000
```

### Test Backend Locally
```bash
cd backend
pip install -r requirements.txt
python app.py
# Open http://localhost:5000/api
```

### Test API Endpoints
```bash
# Health check
curl http://localhost:5000/api/health

# Get messages
curl http://localhost:5000/api/messages

# Create message
curl -X POST http://localhost:5000/api/messages \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello from API!"}'
```

## 🚨 Troubleshooting

### Common Issues

**1. Minikube won't start:**
```bash
# Delete and recreate
minikube delete
minikube start --cpus=4 --memory=8192
```

**2. Pods stuck in Pending:**
```bash
# Check events
kubectl describe pod <pod-name> -n cloud-native-app

# Check node resources
kubectl top nodes
```

**3. Database connection issues:**
```bash
# Check PostgreSQL pod logs
kubectl logs -f deployment/postgres-deployment -n cloud-native-app

# Check backend pod logs
kubectl logs -f deployment/backend-deployment -n cloud-native-app
```

**4. Frontend can't reach backend:**
```bash
# Check if services are running
kubectl get services -n cloud-native-app

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm --restart=Never -- nslookup backend-service
```

### Useful Commands
```bash
# Get all resources
kubectl get all -n cloud-native-app

# View pod logs
kubectl logs -f <pod-name> -n cloud-native-app

# Execute commands in pods
kubectl exec -it <pod-name> -n cloud-native-app -- /bin/bash

# Port forward for debugging
kubectl port-forward service/frontend-service 8080:80 -n cloud-native-app
kubectl port-forward service/backend-service 5000:5000 -n cloud-native-app

# Delete everything
kubectl delete namespace cloud-native-app
```

## 📚 Next Steps

1. **Set up CI/CD**: Configure GitHub Actions secrets
2. **Add Monitoring**: Install Prometheus and Grafana
3. **Production Deployment**: Deploy to cloud Kubernetes (AKS, EKS, GKE)
4. **Security**: Implement proper secrets management
5. **Scaling**: Configure horizontal pod autoscaling

## 🆘 Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review pod logs: `kubectl logs <pod-name> -n cloud-native-app`
3. Check events: `kubectl get events -n cloud-native-app`
4. Verify configurations: `kubectl describe <resource> <name> -n cloud-native-app` 