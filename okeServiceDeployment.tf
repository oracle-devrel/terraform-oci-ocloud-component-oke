# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# initialize the Hashicorp Kubernetes provider and configure it with the .kube/config file from the OKE cluster

provider "kubernetes" {
  host                   = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  config_context         = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["contexts"][0]["name"]

  exec {
    api_version = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["apiVersion"]
    args = [yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][0],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][1],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][2],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][3],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][4],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][5],
      yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][6]]
      command = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["command"]
  }
}

# test demo deployment of a nginx web server according to
# documentation https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started

# define a new Kubernetes namespace first

resource "kubernetes_namespace" "test" {
  depends_on = [oci_containerengine_node_pool.oke_node_pool]
  metadata {
    name = "nginx"
  }
}


# deploy an Nginx deployment onto Kubernetes with two instances of an nginx container, taken from the official Docker registry

resource "kubernetes_deployment" "test" {
  depends_on = [oci_containerengine_node_pool.oke_node_pool]
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# expose the Nginx deployment as a service with the type Load Balancer. This automatically creates an OCI Load Balancer with the Kubernetes Nginx Deployment in its backend set. Make sure (depends_on) that the OKE node pool is completely finished.

resource "kubernetes_service" "test" {
  depends_on = [oci_containerengine_node_pool.oke_node_pool]
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

# After finishing the Nginx service (depends_on), wait 2 minutes to be sure that the public IP address of the Load Balancer is available.

resource "time_sleep" "wait_120_seconds" {
  depends_on = [kubernetes_service.test] 
  create_duration = "120s"
}

# After the 2 minutes have elapsed (depends_on), look up the load balancers public IP address

data "kubernetes_service" "nginx" {
  depends_on = [time_sleep.wait_120_seconds]
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
}

# send the Kubernetes service load balancer public endpoint URL to output

output "kubernetes_service_load_balancer_public_endpoint_url" {
  value = "http://${data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip}"
}

