# argocd-devops


Instalar Terraform

Verificar instruções em:
https://developer.hashicorp.com/terraform/downloads

Iniciando o terraform

```
terraform -chdir=./provision init
```

---
ArgoCD

Export svc

```
kubectl -n argocd port-forward svc/argocd-server 8080:80
```


```
helm create cluster
```
