# 🧩 Cloud-Native Multi-Service Application

> **A complete 3-tier cloud-native application demonstrating modern DevOps practices, containerization, orchestration, and CI/CD automation.**

## 🎯 Why I Built This Project

### **Learning Objectives**
I created this project to gain hands-on experience with **modern cloud-native technologies** and **DevOps practices** that are essential in today's software industry. This project demonstrates my ability to:

- **Design and implement microservices architecture**
- **Containerize applications using Docker**
- **Orchestrate services with Kubernetes**
- **Automate deployment pipelines with CI/CD**
- **Manage infrastructure as code**
- **Implement production-ready monitoring and scaling**

### **What I Learned**
Through building this project, I gained deep understanding of:

- **Container Orchestration**: Kubernetes deployments, services, configmaps, secrets
- **Microservices Communication**: Service-to-service communication patterns
- **CI/CD Automation**: GitHub Actions workflows, automated testing, and deployment
- **Infrastructure Management**: Kubernetes manifests, resource management, scaling
- **Production Best Practices**: Health checks, resource limits, security configurations
- **Cloud-Native Development**: Multi-stage Docker builds, environment management

---

## 🏗️ Architecture Overview

This is a **3-tier cloud-native application** with the following architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Database      │
│   (React)       │◄──►│   (Flask)       │◄──►│   (PostgreSQL)  │
│   + NGINX       │    │   + Gunicorn    │    │   + Persistent  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Kubernetes    │
                    │   Orchestration │
                    │   + Services    │
                    └─────────────────┘
```

### **Technology Stack**

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | React 18 + NGINX | Modern UI with static file serving |
| **Backend** | Python Flask + Gunicorn | RESTful API with production WSGI |
| **Database** | PostgreSQL 13 | Reliable relational database |
| **Containerization** | Docker | Application packaging and isolation |
| **Orchestration** | Kubernetes | Service orchestration and scaling |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Registry** | Docker Hub | Container image storage |

---

## 📁 Project Structure

```
cloud-native-multi-service-app/
├── 📂 frontend/                    # React application
│   ├── 📄 src/                    # React source code
│   ├── 📄 public/                 # Static assets
│   ├── 📄 package.json            # Node.js dependencies
│   ├── 📄 Dockerfile              # Multi-stage Docker build
│   └── 📄 nginx.conf              # NGINX configuration
│
├── 📂 backend/                    # Flask API
│   ├── 📄 app.py                  # Flask application
│   ├── 📄 requirements.txt        # Python dependencies
│   └── 📄 Dockerfile              # Python container
│
├── 📂 k8s-manifests/              # Kubernetes configurations
│   ├── 📄 namespace.yaml          # Application namespace
│   ├── 📄 secrets.yaml            # Database credentials
│   ├── 📄 configmap.yaml          # Application configuration
│   ├── 📄 postgres-deployment.yaml # Database deployment
│   ├── 📄 backend-deployment.yaml # API deployment
│   ├── 📄 frontend-deployment.yaml # Frontend deployment
│   └── 📄 ingress.yaml            # Traffic routing
│
├── 📂 .github/workflows/          # CI/CD pipeline
│   └── 📄 ci-cd.yml              # GitHub Actions workflow
│
├── 📄 README.md                   # Project documentation
├── 📄 SETUP.md                    # Local setup guide
├── 📄 DEPLOYMENT.md               # Production deployment guide
└── 📄 .gitignore                  # Git ignore rules
```

---

## 🖼️ Screenshots

### **1. Kubernetes Deployment Status**
![Kubernetes Deployment](Screenshots/kubectl-get-all.png)
*All services successfully deployed and running in Kubernetes cluster*

### **2. Docker Images Built and Pushed**
![Docker Images](Screenshots/docker-images.png)
*Custom Docker images built and pushed to Docker Hub registry*

### **3. Application Running in Browser**
![React Application](Screenshots/react-app-running.png)
*Frontend application accessible and communicating with backend API*

### **4. CI/CD Pipeline Success**
![GitHub Actions Workflow](Screenshots/workflow-run.png)
*Automated CI/CD pipeline successfully running tests, building Docker images, and pushing to registry*

---

## 🚀 Key Features

### **✅ Production-Ready Architecture**
- **High Availability**: Multiple replicas for frontend and backend
- **Health Checks**: Liveness and readiness probes for all services
- **Resource Management**: CPU and memory limits configured
- **Security**: Non-root containers, secrets management

### **✅ Automated CI/CD Pipeline**
- **Automated Testing**: Frontend and backend tests on every commit
- **Docker Builds**: Multi-stage builds for optimized images
- **Image Registry**: Automatic pushing to Docker Hub
- **Deployment**: Kubernetes deployment automation

### **✅ Scalability & Monitoring**
- **Horizontal Scaling**: Kubernetes deployments with multiple replicas
- **Load Balancing**: Service discovery and load balancing
- **Health Monitoring**: Built-in health check endpoints
- **Resource Optimization**: Efficient container resource usage

---

## 🛠️ Getting Started

### **Prerequisites**
- Docker Desktop
- Minikube (for local Kubernetes)
- kubectl CLI
- Node.js 18+
- Python 3.9+

### **Quick Start**
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/cloud-native-multi-service-app.git
cd cloud-native-multi-service-app

# 2. Build and push Docker images
docker build -t yourusername/frontend-app:latest ./frontend
docker build -t yourusername/backend-api:latest ./backend
docker push yourusername/frontend-app:latest
docker push yourusername/backend-api:latest

# 3. Start Minikube
minikube start --cpus=2 --memory=4096

# 4. Deploy to Kubernetes
kubectl apply -f k8s-manifests/

# 5. Access the application
minikube service frontend-service -n cloud-native-app
```

For detailed setup instructions, see [SETUP.md](SETUP.md).

---

## 🔧 Configuration

### **Environment Variables**
- `DB_HOST`: PostgreSQL service hostname
- `DB_PORT`: Database port (5432)
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password (from Kubernetes secrets)

### **Kubernetes Resources**
- **Namespace**: `cloud-native-app`
- **Services**: ClusterIP for internal, NodePort for external access
- **Replicas**: 2 frontend, 2 backend, 1 database
- **Resources**: Configured with appropriate CPU/memory limits

---

## 📊 Performance & Monitoring

### **Resource Usage**
- **Frontend**: 64-128MB RAM, 50-100m CPU
- **Backend**: 128-256MB RAM, 100-200m CPU
- **Database**: 256-512MB RAM, 250-500m CPU

### **Health Endpoints**
- Frontend: `GET /` (served by NGINX)
- Backend: `GET /api/health` (Flask health check)
- Database: `pg_isready` (PostgreSQL readiness)

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test Phase**
   - Install dependencies
   - Run frontend tests
   - Build frontend application
   - Run backend tests

2. **Build & Push Phase**
   - Build Docker images
   - Push to Docker Hub with commit SHA tags

3. **Deploy Phase**
   - Update Kubernetes manifests
   - Deploy to cluster
   - Wait for deployment completion

---

## 🚀 Deployment Options

### **Local Development**
- Minikube for local Kubernetes cluster
- Perfect for development and testing

### **Cloud Deployment**
- **Azure AKS**: Azure Kubernetes Service
- **AWS EKS**: Amazon Elastic Kubernetes Service
- **Google GKE**: Google Kubernetes Engine

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed cloud deployment instructions.

---

## 🔒 Security Features

- **Secrets Management**: Database credentials stored in Kubernetes secrets
- **Non-root Containers**: All containers run as non-root users
- **Network Policies**: Isolated network communication
- **Resource Limits**: Prevent resource exhaustion attacks

---

## 📈 Future Enhancements

- **Monitoring**: Prometheus + Grafana integration
- **Logging**: ELK stack for centralized logging
- **Service Mesh**: Istio for advanced traffic management
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA)
- **Blue-Green Deployment**: Zero-downtime deployments

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

## 📞 Contact

- **GitHub**: [@yourusername](https://github.com/himanshu3024)
- **LinkedIn**: [Your LinkedIn Profile](https://www.linkedin.com/in/himanshu-gandhi-891204160/)
- **Email**: gandhi111000@hotmail.com

---

**⭐ Star this repository if you found it helpful!** 