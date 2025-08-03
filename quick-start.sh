#!/bin/bash

# 🚀 Quick Start Script for Cloud-Native Multi-Service App
# This script will help you get started quickly with the project

set -e  # Exit on any error

echo "🧩 Cloud-Native Multi-Service App - Quick Start"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker Desktop first."
        exit 1
    fi
    
    # Check Minikube
    if ! command -v minikube &> /dev/null; then
        print_error "Minikube is not installed. Please install Minikube first."
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Get Docker Hub username
get_docker_username() {
    print_status "Please enter your Docker Hub username:"
    read -r DOCKER_USERNAME
    
    if [ -z "$DOCKER_USERNAME" ]; then
        print_error "Docker Hub username cannot be empty!"
        exit 1
    fi
    
    print_success "Using Docker Hub username: $DOCKER_USERNAME"
}

# Update Docker image names in files
update_docker_images() {
    print_status "Updating Docker image names in configuration files..."
    
    # Update frontend deployment
    sed -i.bak "s/yourusername/$DOCKER_USERNAME/g" k8s-manifests/frontend-deployment.yaml
    sed -i.bak "s/yourusername/$DOCKER_USERNAME/g" k8s-manifests/backend-deployment.yaml
    sed -i.bak "s/yourusername/$DOCKER_USERNAME/g" .github/workflows/ci-cd.yml
    
    # Remove backup files
    rm -f k8s-manifests/*.bak .github/workflows/*.bak
    
    print_success "Docker image names updated!"
}

# Build frontend
build_frontend() {
    print_status "Building frontend application..."
    
    cd frontend
    npm install
    npm run build
    cd ..
    
    print_success "Frontend built successfully!"
}

# Build and push Docker images
build_docker_images() {
    print_status "Building and pushing Docker images..."
    
    # Check if user is logged into Docker Hub
    if ! docker info | grep -q "Username"; then
        print_warning "You are not logged into Docker Hub. Please run 'docker login' first."
        print_status "After logging in, run this script again."
        exit 1
    fi
    
    # Build frontend image
    print_status "Building frontend Docker image..."
    docker build -t "$DOCKER_USERNAME/frontend-app:latest" ./frontend
    docker push "$DOCKER_USERNAME/frontend-app:latest"
    
    # Build backend image
    print_status "Building backend Docker image..."
    docker build -t "$DOCKER_USERNAME/backend-api:latest" ./backend
    docker push "$DOCKER_USERNAME/backend-api:latest"
    
    print_success "Docker images built and pushed successfully!"
}

# Start Minikube
start_minikube() {
    print_status "Starting Minikube..."
    
    # Check if Minikube is already running
    if minikube status | grep -q "Running"; then
        print_warning "Minikube is already running!"
    else
        minikube start --cpus=4 --memory=8192 --disk-size=20g
    fi
    
    # Enable ingress addon
    minikube addons enable ingress
    
    print_success "Minikube started successfully!"
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Apply all manifests
    kubectl apply -f k8s-manifests/
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n cloud-native-app
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n cloud-native-app
    kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment -n cloud-native-app
    
    print_success "Deployment completed successfully!"
}

# Show application status
show_status() {
    print_status "Application Status:"
    echo ""
    
    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip)
    
    echo "🌐 Frontend URL: http://$MINIKUBE_IP:30001"
    echo "🔧 Backend API: http://$MINIKUBE_IP:30001/api"
    echo ""
    
    echo "📊 Pod Status:"
    kubectl get pods -n cloud-native-app
    
    echo ""
    echo "🔗 Services:"
    kubectl get services -n cloud-native-app
    
    echo ""
    print_success "Application is ready!"
    print_status "You can access the frontend at: http://$MINIKUBE_IP:30001"
}

# Main execution
main() {
    echo ""
    check_prerequisites
    echo ""
    get_docker_username
    echo ""
    update_docker_images
    echo ""
    build_frontend
    echo ""
    build_docker_images
    echo ""
    start_minikube
    echo ""
    deploy_to_kubernetes
    echo ""
    show_status
    echo ""
    print_success "🎉 Setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Access your application at the URL shown above"
    echo "2. Check the logs if needed: kubectl logs -f <pod-name> -n cloud-native-app"
    echo "3. Scale your application: kubectl scale deployment frontend-deployment --replicas=3 -n cloud-native-app"
    echo "4. Set up monitoring: Follow the instructions in DEPLOYMENT.md"
    echo ""
}

# Run main function
main "$@" 