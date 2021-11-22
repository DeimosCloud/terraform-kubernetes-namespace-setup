locals {
  depends_on = var.create_namespace != true ? [] : [kubernetes_namespace.ns]
}

resource "kubernetes_namespace" "ns" {
  count = var.create_namespace == true ? 1 : 0
  metadata {
    labels      = merge(var.labels, var.namespace_labels)
    annotations = var.namespace_annotations
    name        = var.namespace
  }
}

resource "kubernetes_config_map" "configmap" {
    metadata {
    name          = var.configmap_name
    namespace     = var.namespace
    labels        = var.labels
    generate_name = var.configmap_generate_name
  }

  data = var.configmap_data
  depends_on = [local.depends_on]
}

resource "kubernetes_secret" "configs" {
  metadata {
    name          = var.secret_generate_name == null ? var.secret_name : null
    namespace     = var.namespace
    labels        = var.labels
    generate_name = var.secret_generate_name
  }

  data = var.secret_data
  type = var.secret_type

  depends_on = [local.depends_on]
}

resource "kubernetes_secret" "pull_secret" {
  count = var.pull_secret_name == null ? 0 : 1
  metadata {
    name      = var.pull_secret_name
    namespace = var.namespace
    labels    = var.labels
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.pull_secret_registry}": {
      "auth": "${base64encode("${var.pull_secret_username}:${var.pull_secret_password}")}"
    }
  }
}
DOCKER
  }

  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [local.depends_on]
}