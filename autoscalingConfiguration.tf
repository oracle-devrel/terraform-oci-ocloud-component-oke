# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

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
            initial = var.pool_instance_count
            max = tostring(tonumber(var.pool_instance_count) * 3)  //scale up to triple number of initial VMs
            min = var.pool_instance_count
        }
        display_name = "${local.service}_app_autoscaling_policy"
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
                    value = "70"
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
    display_name = "${local.service}_app_autoscaling_configuration"   
    is_enabled = "true"
}

output "auto_scaling_configuration_id" {
  value = oci_autoscaling_auto_scaling_configuration.auto_scaling_configuration.id
}
