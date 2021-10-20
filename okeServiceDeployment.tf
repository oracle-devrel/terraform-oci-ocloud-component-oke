# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes

#terraform {
#  required_providers {
#    kubernetes = {
#      source  = "hashicorp/kubernetes"
#      version = "1.13"
#    }
#  }
#}



# define the Kubernetes provider. Get the Kubernetes configuration and extract the cluster certificate, extract the commands and arguments to create an ExecCredential and execute this command
provider "kubernetes" {
  version                = "< 2.2.0"
  load_config_file       = "false"        # Workaround for tf k8s provider < 1.11.1 to work with ORM
  config_path            = "~/.kube/config"
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  host                   = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["server"]
  exec {
    api_version = "client.authentication.k8s.io/v1beta1" # Workaround for tf k8s provider < 1.11.1 to work with orm - yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["apiVersion"]
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

# test demo deployment of a nginx web server
# taken from https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started and adapted to this case

# define a new Kubernetes namespace first
resource "kubernetes_namespace" "test" {
  metadata {
    name = "nginx"
  }
}

# deploy a Nginx deployment onto Kubernetes with two instances of an nginx container, taken from the official Docker registry

resource "kubernetes_deployment" "test" {
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

# send the Nginx service load balancer public endpoint URL to output

output "nginx_load_balancer_public_endpoint_url" {
  value = "http://${data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip}"
}
