# Instalação do um Cluster Kubernetes na Digital Ocean utilizando Terraform

```
terraform -v
```
```
terraform fmt
```
```
terraform validate
```

```
terraform init
```

```
terraform plan -out="tfplan.out"
```
```
terraform apply "tfplan.out"
```

```console
sudo apt-get update
```

## INSTALAÇÃO DO [CONTAINERD](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
[Este vídeo](https://www.youtube.com/watch?v=DXw6NODrIpc) pode te ajudar nesta instalação.  
Não esqueça de habilitar o swap off. Esta configuração evita perda de performance e está aderente ao design e uso de containers limitando até 100% do recurso e não mais que isso. 

```console
swapoff -a

```

PRÉ-INSTALAÇÃO  

```console
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
```
INSTALAÇÃO  

```console
sudo apt-get install containerd -y
	
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd
```
## [INSTALAÇÃO KUBELET KUBEADM KUBECTL](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

Essa trinca (kubelet, kubeadm e kubectl) é necessária para podermos levantar o nosso cluster kubernetes Multi Control Plane!

PRÉ-INSTALAÇÃO  

Verifique se o módulo ***br_netfilter*** está carregado. Isso pode ser feito da seguinte forma:

```console
lsmod | grep br_netfilter
```

Caso não encontre, carregue-o da seguinte forma:
```console
sudo modprobe br_netfilter
```
As configurações dos nós linux no que se refere ao iptables precisam estar corretas para que a comunicação do cluster funcione. O ***net.bridge.bridge-nf-call-iptables*** tem que estar igual a 1 na configuração do ***sysctl***. 

```console
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
```  
INSTALAÇÃO  

Atualize a indexação/lista de pacotes e instale os pacotes necessários para poder utilizar o repositório do kubernetes:

```console
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```  

Baixe a chave de assinatura pública do Google Cloud:
```console
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

Adicione o repositório do kubernetes:
```console
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
Atualize a indexação/lista de pacotes e instale a trinca kubelet, kubeadm e kubectl. Ao final, fixe a versão instalada com o ***hold*** ;)
```console
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
## [INICIANDO SEU CLUSTER KUBERNETES 

Control Plane para executar:
```console
sudo kubeadm init
```
Pronto! Isso irá iniciar o seu Cluster Kubernetes.
Ao final, você terá os comandos para gerenciar o seu cluster e colocar os Nós (workers) no cluster.  

Exemplo:

>Para iniciar usando seu cluster, voce rodar com o seu usário:

```console
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Instale um plugin referente ao Container Network Interface (CNI). Neste caso, vamos instalar o Weave Net:
```console
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
Agora sim você pode ver os componentes do Control Plane inicializando:
```console
kubectl get nodes
kubectl get pod -n kube-system -w
```
## APROVEITE O SEU CLUSTER

Que tal através do Control Plane criar ou escalar um Pod?!
```console
kubect create deployment nginx --image nginx
kubectl scale deployment nginx --replicas 5
```

Pause ou desligue um Control Plane e veja se ainda conseguirá gerenciar os recursos do seu cluster ;)

Instale o Autocomplete
```console
source <(kubectl completion bash)
```
Verifique os nodes e pods
```console
kubectl get nodes
kubectl get pods
```

## EXTRA
## INSTALE O ISTIO 1.11.4
```console
curl -L https://istio.io/downloadIstio | sh -
ls
export PATH="$PATH:/root/istio-1.11.4/bin"
hostname
cd istio-1.11.4/
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
kubectl get namespaces 
kubectl get namespaces default -o yaml
ls
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
vim samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get pods -n istio-system
kubectl get services
kubectl get pods
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
kubectl get pods -n istio-system
kubectl get namespaces --all-namespaces
kubectl get pods -n default 
kubectl describe pods details-v1-79f774bdb9-pltkl
kubectl get services -n istio-system 
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
vim samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateways.networking.istio.io 
kubectl get gateway
kubectl describe gateways.networking.istio.io 
kubectl get svc istio-ingressgateway -n istio-system
kubectl get svc -n istio-system 
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
kubectl get svc -n istio-system 
kubectl get svc -n istio-system | grep kiali
kubectl port-forward svc/kiali 20001:20001 -n istio-system --address 0.0.0.0
```
