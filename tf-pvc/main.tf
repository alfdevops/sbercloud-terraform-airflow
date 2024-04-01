provider "kubernetes" {
# Ensure that the right context is used from your local kubeconfig
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_redis" {
  metadata {
    name      = "redis-db-airflow-redis-0"
    namespace = "airflow"
    labels    = {
      "failure-domain.beta.kubernetes.io/region" = "ru-moscow-1"
      "failure-domain.beta.kubernetes.io/zone"   = "ru-moscow-1a"
    }
    annotations = {
      "everest.io/disk-volume-type"                   = "SSD"
      "volume.beta.kubernetes.io/storage-provisioner" = "everest-csi-provisioner"
      "volume.kubernetes.io/storage-provisioner"      = "everest-csi-provisioner"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }  
    storage_class_name = "csi-disk"
  } 
}

resource "kubernetes_persistent_volume_claim" "pvc_postgres" {
  metadata {
    name      = "data-airflow-postgresql-0"
    namespace = "airflow"
    labels    = {
      "failure-domain.beta.kubernetes.io/region" = "ru-moscow-1"
      "failure-domain.beta.kubernetes.io/zone"   = "ru-moscow-1a"
    }
    annotations = {
      "everest.io/disk-volume-type"                   = "SSD"
      "volume.beta.kubernetes.io/storage-provisioner" = "everest-csi-provisioner"
      "volume.kubernetes.io/storage-provisioner"      = "everest-csi-provisioner"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "csi-disk"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_triggerer" {
  metadata {
    name = "logs-airflow-triggerer-0"
    namespace = "airflow"
    labels    = {
      "failure-domain.beta.kubernetes.io/region" = "ru-moscow-1"
      "failure-domain.beta.kubernetes.io/zone"   = "ru-moscow-1a"
    }
    annotations = {
      "everest.io/disk-volume-type"                   = "SSD"
      "volume.beta.kubernetes.io/storage-provisioner" = "everest-csi-provisioner"
      "volume.kubernetes.io/storage-provisioner"      = "everest-csi-provisioner"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = "csi-disk"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_worker" {
  metadata {
    name      = "logs-airflow-worker-0"
    namespace = "airflow"
    labels    = {
      "failure-domain.beta.kubernetes.io/region" = "ru-moscow-1"
      "failure-domain.beta.kubernetes.io/zone"   = "ru-moscow-1a"
    }
    annotations = {
      "everest.io/disk-volume-type"                   = "SSD"
      "volume.beta.kubernetes.io/storage-provisioner" = "everest-csi-provisioner"
      "volume.kubernetes.io/storage-provisioner"      = "everest-csi-provisioner"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = "csi-disk"
  }
}
