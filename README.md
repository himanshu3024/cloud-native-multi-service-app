# 🧩 Cloud-Native Multi-Service App with Docker, Kubernetes, and CI/CD

## 🚀 Project Overview
A complete 3-tier cloud-native application demonstrating Docker containerization, Kubernetes orchestration, and automated CI/CD pipeline.

## 🏗️ Architecture
- **Frontend**: React app served via NGINX
- **Backend**: Python Flask REST API
- **Database**: PostgreSQL
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana (Optional)

## 📁 Project Structure
```
multi-service-app/
├── frontend/                 # React application
│   ├── public/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── backend/                  # Flask API
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── k8s-manifests/           # Kubernetes configurations
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── postgres-deployment.yaml
│   └── services.yaml
├── .github/workflows/       # CI/CD pipeline
│   └── ci-cd.yml
└── README.md
```

## 🛠️ Prerequisites
- Docker Desktop
- Minikube
- kubectl
- Node.js (for React development)
- Python 3.9+
- Git

## 🚀 Quick Start
1. Clone this repository
2. Follow the setup guide in SETUP.md
3. Run `minikube start`
4. Deploy with `kubectl apply -f k8s-manifests/`
5. Access the application via `minikube service frontend-service`

## 📚 Documentation
- [Setup Guide](SETUP.md)
- [Development Guide](DEVELOPMENT.md)
- [Deployment Guide](DEPLOYMENT.md) 