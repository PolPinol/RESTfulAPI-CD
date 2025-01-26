# RESTfulAPI-CD

Pre-requisites:
- AWS CLI
- EKSCTL
- Kubectl

Step 1: Creating EKS cluster from AWS:

```
eksctl create cluster \
  --name restapi-eks \
  --region us-west-2 \
  --nodes 1
```

Add context to you local k8s config file:

```
aws eks --region us-west-2 update-kubeconfig --name restapi-eks
```

Verify:

```
kubectl get nodes
```

Step2: Install ArgoCD:

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify:

```
kubectl get pods -n argocd
```

Expose Argo CD Server to localhost:8080.

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Retrieve the initial password:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

(Optional) Change the password from ArgoCD:
```
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "<NEW_PASSWORD_ENCODED_IN_BASE64>",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
```


Step 3: Deploy Your Application Using Argo CD

```
kubectl apply -f app/RESTfulAPI-app.yaml
````


