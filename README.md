# Terraform Kubernetes Cert Manager Module
A terraform module to setup a namespace. It creates a namespace and configures secrets, pull secrets and configs.

## Usage

```hcl
module "apps_namespace_setup" {
  source = "."
  labels = local.common_labels

  namespace = local.apps_namespace
  namespace_labels = {
    "argocd.argoproj.io/instance" = "argocd-applications" # Allow Argocd admit it without destruction
  }
  namespace_annotations = {
    "linkerd.io/inject"                     = "enabled"
    "config.linkerd.io/skip-outbound-ports" = "4222,3306,6379" #nats, mysql and redis
  }

  secret_data = {
    "postgres-user"     = local.db_user_name
    "postgres-password" = module.postgres.generated_user_password
    "postgres-host"     = module.postgres.private_ip_address
    "postgres-database" = local.db_name
    "ratings-database"  = local.ratings_db_name
    "redis-host"        = module.redis.host
    "dns_solver.json"   = module.dns_solver_sa.key
  }

  pull_secret_name     = "${var.project_name}-pull-secret"
  pull_secret_registry = local.registry_server
  pull_secret          = module.gcr_reader_service_account.key
  depends_on           = [module.gke_cluster]
}
```

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally.

And install `terraform-docs` with
```bash
go get github.com/segmentio/terraform-docs
```
or
```bash
brew install terraform-docs.
```

## Contributing

Report issues/questions/feature requests on in the issues section.

Full contributing guidelines are covered [here](CONTRIBUTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| kubernetes | >= 1.13 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | >= 1.13 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_namespace | Whether to create namespace or not | `bool` | `true` | no |
| labels | Extra labels to be added to all created resources | `map` | `{}` | no |
| namespace | the name of the namespace to be created | `any` | n/a | yes |
| namespace\_annotations | Annotations to be applied to the created namespace | `map` | `{}` | no |
| namespace\_labels | Labels to be applied to the created namespace | `map` | `{}` | no |
| pull\_secret\_name | The name of the pull secret | `any` | `null` | no |
| pull\_secret\_password | The base64 encoded password to be used as pull secret creds | `any` | `null` | no |
| pull\_secret\_registry | Registry server URL | `any` | `null` | no |
| pull\_secret\_username | The username for the pull secret e.g \_json\_key for GCP SA | `any` | `null` | no |
| secret\_data | data to be populated into config secret created in namespace | `map` | `{}` | no |
| secret\_generate\_name | Prefix, used by the server, to generate a unique name.This value will also be combined with a unique suffix. If provided, it'll override the name argument | `any` | `null` | no |
| secret\_name | The name of the secret to create and store variables as | `string` | `"config"` | no |
| secret\_type | The type of the secret to create. (default Opaque) | `string` | `"Opaque"` | no |
| configmap\_data | data to be populated into configmap created in namespace | `map` | `{}` | no |
| configmap\_generate\_name | Prefix, used by the server, to generate a unique name.This value will also be combined with a unique suffix. If provided, it'll override the name argument | `any` | `null` | no |
| configmap\_name | The name of the configmap to create and store variables as | `string` | `"config"` | no |
## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
