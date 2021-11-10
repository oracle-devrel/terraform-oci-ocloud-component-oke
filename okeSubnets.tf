variable "ports_between_nodepool_subnet_and_k8slb_subnet" {
  type    = list(string)
  default = ["30198", "10256", "31093", "32551", "30517", "80", "443", "30943", "32206", "31866"]
}
