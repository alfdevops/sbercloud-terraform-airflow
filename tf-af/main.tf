provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "airflow" {
  name           = "airflow"
  namespace      = "airflow"
  repository     = "https://airflow.apache.org"
  chart          = "airflow"
  wait_for_jobs  = false
  wait           = false
  atomic         = false
  values = [
    file("${path.module}/override.yml")
  ]
}
