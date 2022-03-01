<!-- Copyright (c) 2020 Oracle and/or its affiliates.
Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. -->


[![Deploy on Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-devrel/terraform-oci-ocloud-app/releases/latest/download/ocloud-app-latest.zip)

# OCI Ocloud Framework: Application Module

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_terraform-oci-ocloud-app)](https://sonarcloud.io/dashboard?id=oracle-devrel_terraform-oci-ocloud-app)

## Introduction

Oracle Cloud Infrastructure (OCI) allows different deployment models to be applied within a shared network and deployed by the same Infrastructure-as-Code methods. Setting up our operation, we distinguish core and orchestration service API. Core services represent the physical infrastructure in our data center, orchestration services refer to software that runs outside the core service portfolio, interacts with the application code and manipulates the behaviour of virtual instances. Application developers and service operators need to distinguish the following four infrastructure deplyment models designing a multi-server architecture:

* Dedicated Server - virtual machines (VM) or baremetal server that maintain stateful communication interfaces on layer three
* Elastic Compute cluster - one or more VM that scale automatically and maintain a stateless communication interface on layer three
* Container Cluster - one or more dedicated server that host lightweight stand-alone, executable user space images including code, runtime, system tools, system libraries, settings to run on a linux kernel
* Functions, ephemeral, single purpose, self contained, stateless container without API surface, invoked via network protocolls like HTTP

while public cloud providers offer these instance types as product, in OCI we define logical resources including the repective orchestrator. We can rely on managed services for open source orchstratore or choose commercial third-party offerings. We invoke an orchestrator, writing modules for the resource manager. Here we will focus on these three different models:

<img alt="Overview of Host, Node and Container Deployment Models in OCI" src="doc/image/HostNodeContainer.png" title="Overview of Host, Node and Container Deployment Models in OCI">

1. The **Host model** is the one most known from on-premise environments: On a dedicated physical machine, Virtual Machines (VMs) can be deployed that run stateless or stateful applications. OCI offers both ways here: 
    - You can deploy a bare metal host, install the hypervisor and deploy the VMs on top of it. Here, you are responsible for the VMs and the hypervisor layer as well as the Operating System (O/S) of the bare metal host. You will have full root access to the O/S of the bare metal server and it will be inside a Virtual Cloud Network (VCN) that you own.
    - You can deploy a Dedicated VM Host and deploy the VMs on top of it. This is the approach that we use here: You can use Terraform to fully deploy both the Dedicated VM Host as well as the VMs on top of it. Each VM will be instantiated which its own Virtual Network Interface Card (VNIC) which can be individually placed into VCNs and subnets that you own. The Dedicated VM Host itself will be in full control by Oracle, you won't have any O/S access to it and the Dedicated VM Host won't be placed in any VCN.
You can use tools like **Packer** to first build a custom image with all applications and data you need on your VMs before applying Terraform to instatiate the VMs. The ```cloud-init``` option of Terraform gives the opportunity to apply a shell script on the instantiated VMs to add indivdual data or installations immediately after the instantiation. Here, the shell script is added as a base64-encoded attribute to the resource definition of the instance. Through metadata key-value pairs, Terraform can pass parameters to the instance that can be used inside the cloud-init shell script to parameterize the actual shell execution.

The Terraform stack consists of a dedicatedHost.tf file which can be used to create a Dedicated VM Host. By default, this code is commented out because many demo-tenants do not allow the creation of Dedicated VM Hosts by its Service Limits. It can easliy being activated by removing the comments start/end lines.

2. The **Node model** applies the cloud principle to adapt the number of available nodes to the current amount of workload. Here we have primary workloads running that control secondary workloads on top which will be scaled in and out based on on-demand capacity rather than capacitiy from a Dedicated VM Host in order to optimize the costs. The secondary workloads should be stateless in nature since scaling in means that those nodes might be terminated by the Cloud Control at any time if the overall workload would be sufficiently executed by less nodes.
OCI has the following artifacts to create this scenario, which can be fully deployed by Terraform:
    - An Instance Configuration that acts as the blueprint for the pool of secondary workloads VMs. Here you define 
          - a Custom Image that should be used (can be build using **Packer** and you can use ```cloud-init``` provider for further work)
          - the Shape of the pool instances (e.g. *VM.Standard2.1* which means a 1 OCPU Intel X7 VM with network-attached storage)
          - the public part of the **ssh** key pair to access the O/S of the instance
    - The Instance Pool object refers to an Instance Configuration and adds information about in which Availability Domain as well as in which subnet the instance pool's instances' VNICs should be placed. Furthermore you define how many VMs should be started. You can add a load balancer to the instance pool definition in a way that any created instances inside the pool will be part of this load balancer's backend set, so that incoming requests are forwarded to the instance pool instances e.g. in a round-robin-manner. Load balancers also support cookie-badsed session stickyness in case this is needed by stateful applications running in the instance pool instances.
    - The Autoscaling Configuration refers to an Instance Pool and adds policies on when new instances should be automatically added and when instances should be removed. You define the incremental and decremental step size (numbers of instances to be added or removed when a scale-in or scale-out event occurs) as well as the minimum and maximum total number of instances. Two autoscaling policies are supported:
          - Schedule-based Autoscaling: Here the scaling-out and scaling-in rules are defined based on fixed schedules similar to definitions in cron jobs. This is feasible, if regular workload peaks are to be expected like loading data into a Data Warehouse or providing Analytic reporting at certain times during a day, week or month.
          - Metrics-based Autoscaling: Here the scaling-out and scaling-in rules are based on overall instance pool metrics that the instances report using agents to the Cloud Control. OCI allows the following metrics to be used here:
               - CPU Utilization (in percent)
               - Memory Utilization (in percent)
          - In the Autoscaling Configuration you define the percent threshold value above which the pool will scale out (add an instance or instances if the maximum number is not yet reached) and the percent threshold value underneath which the pool will scale in (terminate an instance or instances if the minimum number is not yet reached).

In the scenario, we trigger a 100% CPU utilization process in each new instance pool instance upon instance creation (using ```cloud-init```) that lasts for a number of minutes that the user can define as part of the Terraform stack definition as a variable. So we can optionally demonstrate the scaling-in and scaling-out according to an CPU-utilization based auto-scaling policy.

Further we deploy an httpd server along with a static page (showing a timestamp for the instance creation) on each instance pool instance. This stateless "application" is exposed to the public internet by a load balancer, so you can see the round-robin-fashioned forwarding of requests to the instance pool instances by reloading the page in the browser. The corresponding public load balancer endpoint is displayed a part of the Terraform out parameters. In this stack, the load balancer exposes the "application" with https, using a self-signed certificate that is also created inside the Terraform stack.

The Instance Pool is based on an Instance Configuration derived from a compute instance that is created by the Terraform stack as well. Its display name ends with 'app_demo_instance'. This instance can be disposed once th instance pool is created. However, we keep it here to demonstrate how to create and attach a block volume for user data to thee compute instance in addition to the boot volume.

**Connecting to Compute Instances**

We deploy all compute instances into private networks, i.e. you cannot access those instances through the internet. However, there is often the necessity to ssh into those instances from outside to perform some operational work, edit files or install software. We can use the OCI Bastion Service for this. We use the Bastion Service that has been created by the basic Landing Zone Module inside the app subnet (which will contain the compute instances) to create temporary Bastion sessions to ssh into the machines. We can either use ssh port forwarding or a managed SSH session (prerequisites a Bastion agent present on the target machine) and use the Bastion Host as an internet-facing proxy to privately connect to the target instance using a commmand like this:

```
ssh -i <privateKeyPath> -N -L <localPort>:10.0.0.43:22 -p 22 ocid1.bastionsession.oc1.eu-frankfurt-1.amaaXXXXXXX5zi3cqq@host.bastion.eu-frankfurt-1.oci.oraclecloud.com
```

3. The **Container model** is the preferred cloud model for stateless applications like Functions. OCI offers a fully managed **Kubernetes** Cluster, the OCI Container Engine (OKE). Again, this can be fully deployed using Terraform. 
OKE consist of 
     - the Kubernetes Cluster which provides the Kubernetes API endpoint as well as the Scheduler and Controller Manager. These components are fully managed by Oracle and visible to the customer only using the Kubernetes API (e.g. by using **kubectl** or by deploying *Helm* charts). The customer doesn't have O/S access to this instance and also doesn't have to pay for it. This component is free of charge.
     - the Kubernetes Node Pool that contains the worker nodes. The customer has full root access using *ssh* and has to pay for these VMs. The charges are the regular charges for Linux VMs of the respective shapes -- there is no surcharge for their role being a Kubernetes worker node.
     - further elements are added and terminated according to Kubernetes deployments. E.g. when deploying a Load Balancer service to a Kubernetes cluster like

     
     ```
     kubectl expose deployment myapplication --type=LoadBalancer --name=myapplicationservice
     ```
     
     an OCI Load Balancer is automatically deployed and configured with the worker nodes in its backend set.

When the cluster is ready, the ```.kube/config``` file (which contains the network details like the Kubernetes Cluster's API endpoint's IP address and the authorization certificate) can be dowloaded to a client using the following OCI Command Line Interface (OCI CLI) command :

```
oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.eu-frankfurt-1.aaaaathekubernetesclusterocidlqs27a --file $HOME/.kube/config --region eu-frankfurt-1 --token-version 2.0.0 
export KUBECONFIG=$HOME/.kube/config
```

The Terraform stack creates also an Kubernetes Cluster along with a worker node pool, the contents of the ```.kube/config```file can be directly taken by a corresponding parameter of the Terraform Output.

Then, the client can e.g apply **kubectl** to inspect, create and destroy Kubernetes artifacts:

```
$ kubectl get nodes,pods
NAME               STATUS   ROLES   AGE     VERSION
node/10.0.10.166   Ready    node    7h11m   v1.19.7

NAME                                 READY   STATUS    RESTARTS   AGE
pod/myapplication-588cf6ff66-cq684   1/1     Running   0          6h13m
pod/myapplication-588cf6ff66-hwtgd   1/1     Running   0          6h13m
pod/myapplication-588cf6ff66-q4228   1/1     Running   0          6h15m
```

OCI also offers a registry service (the OCI registry, OCIR) where container images can be stored and retrieved to be deployed to the Kubernetes cluster. OCIR allows registries both being publicly available (free access to anyone) or privately (downloading images prerequisites presenting a SWIFT-compliant API Key, a so called **OCI Auth Token** that is created individually for each OCI User).

Besides deploying Kubernetes artifacts like pods, deployments, services, replicasets etc. using a **kubectl** client, Terraform provides a Kubernetes provider in order to deploy these artifacts as part of the terraform apply process. The ```okeServiceDeployment.tf```shows the steps to take here:

1. Get the OKE Cluster's config file and extract the CA certificate as well as the OCI CLI command (along with the necessary arguments) to create an ExecCredential. This OCI CLI command is executed, so Terraform can authenticate to the Kubernetes API endpoint for further operations.
2. Create a new namespace in Kubernetes.
3. Define further resources like ```kubernetes_service```to deploy artifacts. Kubernetes artifacts are defined by yaml documents and those Terraform resources basically reformat these yaml documents to the HashiCorp Configuration Language (HCL) format.

In this example stack, we deploy a standard NGINX server to the new generated Kubernetes Cluster. We take the standard NGINX image from the official Docker registry, but you can also deploy your own pods from docker images that are stored e.g. in the OCI registry (OCIR).

We deploy this NGINX server as a ```kubernetes_service```with "Load Balancer" as the type using Terraform. The advantage of using Terraform instead of a local **kubectl** client for deploying Kubernetes services is, that those services are also being deleted when destroying the Terraform stack. This is important because deploying a Kubernetes service with "Load Balancer" as type means that an OCI Load Balancer with the Kubernetes deployment of pods in its backend is created outside of the Kubernetes Cluster. So you need to delete the Kubernetes service first when destroying the Terraform stack in order to properly remove this load balancer.

The complete network topology along with the compute instances, load balancers and Kubernetes resources that will be created by running this stack can be seen in this picture below:

<img alt="Network topology of the app stack" src="doc/image/network_topology_app_stack.png" title="Network topology of the app stack">

After the Terraform stack has beeen successfully applied, the following Kubernetes artifacts can been (e.g. by using the cloud shell):

```
$ kubectl get pods,deployments,replicasets,services --namespace nginx
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-5c48f8956d-84456   1/1     Running   0          41m
pod/nginx-5c48f8956d-wwq8s   1/1     Running   0          41m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   2/2     2            2           41m

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-5c48f8956d   2         2         2       41m

NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
service/nginx   LoadBalancer   10.96.113.223   152.70.173.212   80:32177/TCP   33m
```

## Getting Started

Deployment Steps

1. Click on Deploy to Oracle Cloud
2. Login to your tenant
3. Confirm the Terms of Use
4. Enter a meaning full name
5. Select a compartment where the Resource Manager Stack Template will be created
6. Configure mandatory variables 
7. Save the stack
8. Deploy the stack (please check the prerequisites)

Steps to destroy the infrastructure

1. Login to your tenant
2. Choose the Stack to destroy within the Oracle Resource Manager
3. Click the red "Destroy" button
4. Click on the link "Show Advanced Options" in the Destroy menu on the right hand side.
5. Uncheck the "Refresh Resources States Before Checking For Differences" option

<img width="33%" height="33%" alt="Uncheck the &quot;Refresh Resources States Before Checking For Differences&quot; option" src="doc/image/terraform_destroy.png" title="Uncheck the &quot;Refresh Resources States Before Checking For Differences&quot; option">

6. Click the blue "Destroy" button at the bottom of the Destroy menu on the right hand side.

### Prerequisites

The [OCloud Framework] (https://github.com/oracle-devrel/terraform-oci-ocloud-landing-zone) requires that a OCLoud landing zone is deployed first. The landing zone stack instantiates a VCN, a DB compartment with all policies that allows DB Administrators to provision a Database Cloud Service.

## Notes/Issues
MISSING

## URLs
* Nothing at this time

## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open source community.

## License
Copyright (c) 2021 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.
