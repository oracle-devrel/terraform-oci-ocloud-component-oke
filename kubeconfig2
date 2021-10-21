resource "oci_containerengine_cluster" "test-oke-cluster" {
  compartment_id     = local.appdev_compartment_ocid
  kubernetes_version = "v1.20.8"
  name               = "cluster123"
  vcn_id             = local.vcn_id
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.test-oke-cluster.id
}

provider "kubernetes" {
  host                   = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  config_context         = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["contexts"][0]["name"]

  exec {
    api_version = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["apiVersion"]
    args = [yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][0],
      yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][1],
      yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][2],
      yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][3],
      yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][4],
      yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][5],
    yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][6]]
    command = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["command"]
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "example"
  }
}
