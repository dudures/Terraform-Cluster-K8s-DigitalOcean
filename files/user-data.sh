#!/bin/bash

sudo swapoff -a
sudo apt-get update -y
sudo apt upgrade -y
sudo apt-get install git -y

# Pré- instalação do Containerd

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configurações requeridas no sysctl, estas persistem após reiniciar o host.


cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Aplicar as configurações no sysctl sem a necessidade de reiniciar o host
sudo sysctl --system

# Instalação do Contained.

sudo apt-get install containerd -y
	
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd

# Pré-instalação do Kubelet, Kubeadm e Kubectl
# Essa trinca (kubelet, kubeadm e kubectl) é necessária para podermos levantar o  cluster kubernetes.

PRÉ-INSTALAÇÃO

Verifique se o módulo br_netfilter está carregado. Isso pode ser feito da seguinte forma:

lsmod | grep br_netfilter

# Caso não encontre, carregue-o da seguinte forma:

sudo modprobe br_netfilter

# As configurações dos nós linux no que se refere ao 
# iptables precisam estar corretas para que a comunicação do cluster funcione. 
# O net.bridge.bridge-nf-call-iptables tem que estar igual a 1 na configuração do sysctl.

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

# Instalação KUBERNETES
# Atualize a indexação/lista de pacotes e instale os pacotes necessários para poder utilizar o repositório do kubernetes:

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Baixe a chave de assinatura pública do Google Cloud:

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Adicione o repositório do kubernetes:

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualize a indexação/lista de pacotes e instale a trinca kubelet, kubeadm e kubectl. 
# Ao final, fixe a versão instalada com o hold 

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubectl completion bash > /etc/bash_completion.d/kubectl
source < (kubectl completion bash)

