+++
draft = true
date = 2021-01-28T21:38:38Z
title = "Install Kubernetes with k3s on a BareMetal Server for your blog"
description = "Install Kubernetes with k3s on a BareMetal Server for your blog"
slug = ""
authors = ["Nicolas VION"]
tags = ["k3s","devops","ingress","cert-manager","hugo"]
categories = ["k3s","devops","ingress","cert-manager","hugo"]
externalLink = ""
series = []
+++

# Introduction

This article will present you how to install a blog with Hugo on a Kubernetes
Cluster with k3s on a BareMetal Server. This documentation is using an **Ubuntu
Server 20.04**.

# Target

# Kubernetes Installation

First of all, we will install Kubernetes with k3s:

```bash
curl -sfL https://get.k3s.io | sh -
```

And we will modify the ** ** file with the following content:
```yaml
ExecStart=/usr/local/bin/k3s \
    server \
    --disable traefik \
    --no-deploy local-storage \
```

Then, we reload and restart the service:

```bash
systemctl daemon-reload
systemctl restart k3s
```

We should be able to run the following command:

```bash
kubectl get node
```

To complete our installation, we will add the **helm** command:

```bash
VERSION="3.5.1"
curl -LO https://get.helm.sh/helm-v$VERSION-linux-amd64.tar.gz
tar xzfv helm-v${VERSION}-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
```

To use Helm, don't forget to export the **KUBECONFIG** variables:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

# IPTables

If you have existing IPTables rules, don't forget to add this line in order to
allow k8s pod to run:

```bash
# k3s iptables support
/usr/sbin/iptables -A INPUT -i cni0 -j ACCEPT
/usr/sbin/iptables -A INPUT -i flannel.1 -j ACCEPT
```

# Ingress Nginx

We will now deploy the ingress controller. I prefer to use nginx because this is
the ingress I am the most familiar with. We will use the Helm chart with the
following
[values](https://github.com/nicolasvion/k3s-blog-configs/ingress-nginx/values.yaml):

```bash
kubectl create ns ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --namespace ingress-nginx --install nginx -f values.yaml ingress-nginx/ingress-nginx
```

A few notes:
  * Default replica count is 1.
  * Autoscaling has been enabled (1 -> 2)

If everything runs fine, you should have the following results:

```bash
# kubectl -n ingress-nginx get pods
NAME                                              READY   STATUS    RESTARTS   AGE
svclb-nginx-ingress-nginx-controller-xxx          2/2     Running   0          4d16h
nginx-ingress-nginx-controller-xxx                1/1     Running   0         4d16h

# kubectl -n ingress-nginx get svc
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
nginx-ingress-nginx-controller-admission   ClusterIP      10.43.161.45    <none>         443/TCP                      4d16h
nginx-ingress-nginx-controller             LoadBalancer   10.43.162.28    8.8.8.8   80:32155/TCP,443:31492/TCP        4d16h
```

# Cert-Manager

To serve our website, we will use the HTTPS protocol. We will need a SSL
Certificate. To do this, we will use cert-manager with the following
[crds file](https://github.com/nicolasvion/k3s-blog-configs/cert-manager/cert-manager.crds.yaml):

```bash
kubectl create ns cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f ./cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager  --namespace cert-manager
--version v1.1.0 \
# --set installCRDs=true
```

To check the installation:

```bash
# kubectl get pods --namespace cert-manager

NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5c6866597-zw7kh               1/1     Running   0          2m
cert-manager-cainjector-577f6d9fd7-tr77l   1/1     Running   0          2m
cert-manager-webhook-787858fcdb-nlzsq      1/1     Running   0          2m
```

Finally, we will create our
[cluster-issuer](https://github.com/nicolasvion/k3s-blog-configs/cert-manager/cluster-issuer.yaml):

```bash
# Please change the e-mail
kubectl apply -f ./cluster-issuer.yaml
```

Check the cluster-issuer status:

```bash
# kubectl get clusterissuer
NAME               READY   AGE
letsencrypt-prod   True    4d16h
```

To use cert-manager, add these annotations in the ingress file (see example
below):

```yaml
    cert-manager.io/cluster-issuer: letsencrypt-prod
    cert-manager.io/acme-challenge-type: http01
```

# Docker image for Hugo

We will then create a
[deployment](https://github.com/nicolasvion/k3s-blog-configs/app/deployment.yaml)
and an [ingress
entry](https://github.com/nicolasvion/k3s-blog-configs/app/ingress.yaml):

```bash
# Please change hostname in the ingress.yaml file
kubectl create ns www
kubectl -n www apply -f ./deployment.yaml
kubectl -n www apply -f ./ingress.yaml
```

> Note: a custom image has been built. This image will download the website on a
given URL and generate the static content with hugo, and finally serve it with
nginx. Sources can be found [here](https://github.com/nicolasvion/website/blob/main/Dockerfile)

We should have the following result:

```bash
# kubectl -n www get pods
NAME                      READY   STATUS    RESTARTS   AGE
website-767fdd89c-w5r82   1/1     Running   0          32m
website-767fdd89c-b2dl7   1/1     Running   0          31m

# kubectl -n www get certificate
NAME                 READY   SECRET               AGE
mywebsite-com-tls   True     mywebsite-com-tls   4d16h

# kubectl -n www get ingress
NAME                 CLASS    HOSTS            ADDRESS        PORTS     AGE
mywebsite-com-ing    <none>   mywebsite.com    8.8.8.8        80, 443   4d16h
```

> Note: if you want to update your website content, you just have to **update your
git repo** (the docker image will build it and run it) and **delete your pods** with
the following command:

```bash
for i in $(kubectl -n www get pods | awk '{print $1}' | grep -v NAME)\ndo\nkubectl -n www delete pods $i\ndone
```
