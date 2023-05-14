resource "kind_cluster" "default" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    kind_cluster.default
  ]
}

## Ref: https://bit.ly/3L1oCq2
data "external" "env" {
  program = ["${path.module}/env.sh"]
}

resource "kubernetes_secret" "create_git_private_repo_secret" {
  type = "Opaque"
  metadata {
    name      = "argocd-git-secret"
    namespace = helm_release.argocd.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    "url"      = "https://github.com/erikyami/argocd-devops.git"
    "username" = "not-used"
    "password" = data.external.env.result["gh_token"]
  }

  depends_on = [
    kind_cluster.default
  ]
}