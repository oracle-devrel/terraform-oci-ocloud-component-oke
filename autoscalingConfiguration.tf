# auto-scaling configuration including one policy for the instance pool
# scales out when CPU load > 80%, scales in when CPU load < 30%

resource "oci_autoscaling_auto_scaling_configuration" "auto_scaling_configuration" {
    auto_scaling_resources {
        id = oci_core_instance_pool.instance_pool.id
        type = "instancePool"
    }
    compartment_id = local.appdev_compartment_ocid
    policies {
        policy_type = "threshold"
        capacity {
            initial = "2"
            max = "6"
            min = "2"
        }
        display_name = "${var.service}-0-app-autoscaling-policy"
        is_enabled = "true"
        rules {
            action {
                type = "CHANGE_COUNT_BY"
                value = "1"
            }
            display_name = "Scale Out Rule"
            metric {
                metric_type = "CPU_UTILIZATION"
                threshold {
                    operator = "GT"
                    value = "80"
                }
            }
        }
        rules {
            action {
                type = "CHANGE_COUNT_BY"
                value = "-1"
            }
            display_name = "Scale In Rule"
            metric {
                metric_type = "CPU_UTILIZATION"
                threshold {
                    operator = "LT"
                    value = "30"
                }
            }
        }

    }
    cool_down_in_seconds = "300"
    display_name = "${var.service}-0-app-autoscaling-configuration"   
    is_enabled = "true"
}
