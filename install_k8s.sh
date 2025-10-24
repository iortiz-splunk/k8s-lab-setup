#!/bin/bash
# This script installs K3s (a lightweight Kubernetes distribution), kubectl, and Helm.

set -e # Exit immediately if a command exits with a non-zero status.

echo "Starting Kubernetes (K3s) installation..."

# Update and upgrade system packages
sudo apt update -y
sudo apt upgrade -y

# --- Install K3s (Lightweight Kubernetes) ---
echo "Installing K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable-agent" sh -

# Verify K3s service is active
echo "Verifying K3s service status..."
sudo systemctl status k3s --no-pager

# Wait for K3s kubeconfig to be generated
echo "Waiting for K3s kubeconfig file to be generated..."
for i in $(seq 1 10); do # Try for up to 100 seconds (10 * 10s)
  if [ -f /etc/rancher/k3s/k3s.yaml ]; then
    echo "K3s kubeconfig found!"
    break
  fi
  echo "Waiting for /etc/rancher/k3s/k3s.yaml (attempt $i/10)..."
  sleep 10
done

if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
  echo "Error: K3s kubeconfig file not found after waiting. K3s installation might have failed."
  exit 1
fi

# --- Set Kubeconfig for the default user (ubuntu) ---
echo "Setting up Kubeconfig for the default user (ubuntu)..."

# Define the ubuntu user's home directory and user/group IDs
UBUNTU_HOME="/home/ubuntu"
UBUNTU_USER="ubuntu"
# Get UID and GID for the ubuntu user
UBUNTU_UID=$(id -u ${UBUNTU_USER})
UBUNTU_GID=$(id -g ${UBUNTU_USER})

# Create the .kube directory in the ubuntu user's home
mkdir -p ${UBUNTU_HOME}/.kube

# Copy the K3s kubeconfig to the ubuntu user's .kube directory
sudo cp /etc/rancher/k3s/k3s.yaml ${UBUNTU_HOME}/.kube/config

# Change ownership of the kubeconfig file to the ubuntu user
sudo chown ${UBUNTU_UID}:${UBUNTU_GID} ${UBUNTU_HOME}/.kube/config

# Set appropriate permissions (read/write for owner only)
chmod 600 ${UBUNTU_HOME}/.kube/config

# Verify K3s's kubectl can connect using the ubuntu user's kubeconfig
echo "Verifying K3s's kubectl installation and connection for ubuntu user..."
# Explicitly set KUBECONFIG for this check, as the shell running the script is root
KUBECONFIG=${UBUNTU_HOME}/.kube/config /usr/local/bin/kubectl get nodes || true

# --- Install Helm ---
echo "Installing Helm..."
HELM_VERSION="v3.13.2" # You can update this to the latest stable version
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh --version ${HELM_VERSION}

# Verify Helm installation
echo "Verifying Helm installation..."
# Explicitly set KUBECONFIG for this check
KUBECONFIG=${UBUNTU_HOME}/.kube/config helm version || true

echo "Kubernetes (K3s), kubectl, and Helm installation complete!"