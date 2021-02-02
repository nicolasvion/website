+++
draft = true
date = 2021-01-28T21:38:38Z
title = "Install a kubernetes on a BareMetal Server for your blog"
description = "Install a kubernetes on a BareMetal Server for your blog"
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

# Cert-Manager

# Docker image for Hugo
