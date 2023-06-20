---
title: Guidance for Automated Provisioning of Amazon Elastic Kubernetes Service (EKS) using Terraform Implementation Guide
summary: "Use EKS Bluprints to deploy Amazon Elastic Kubernetes Service (EKS) with HashiCorp Terraform Open Source software."
published: true
hide_sidebar: false
sidebar: EKSTerraform_sidebar
permalink: compute/automated-provisioning-of-amazon-eks-using-terraform.html
folder: guides
tags: compute
layout: page
---

---

## Introduction

This user guide is for anyone interested in efficiently deploying Amazon Elastic Kubernetes Service (EKS) that complements open-source
documentation for EKS Blueprints, available in the [AWS Solutions Library open-source GitHub repository](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform){:target="_blank"}.
It introduces common concepts, specific details for configuration of EKS for selected use cases, and step-by-step instructions on how to deploy that EKS Blueprint using [HashiCorp Terraform](https://www.terraform.io/){:target="_blank"} Open Source Infrastructure as Code
(IaC) automation software.

By following this guide, you will be able to:

-   Familiarize yourself with the concepts of EKS Blueprints

-   Learn ways to customize those Blueprints through parameters

-   Deploy an Amazon EKS cluster with a new Amazon Virtual Private Cloud
    (Amazon VPC)

-   Deploy an Amazon EKS cluster with operational software and [Argo
    CD](https://argo-cd.readthedocs.io/en/stable/core_concepts/){:target="_blank"}, a
    GitOps tool used for deployment of both add-on components and
    applications, into an Amazon EKS cluster

-   Deploy an Amazon EKS cluster with [Apache
    Spark](https://spark.apache.org/){:target="_blank"} and other related add-ons for data
    analytics

-   If needed: properly clean-up and destroy an Amazon EKS cluster
    deployment provisioned using an EKS Blueprint

Finally, there are tips on support and troubleshooting at the end of
this guide.

## What are EKS Blueprints?

EKS Blueprints help you compose complete [EKS clusters](https://aws.amazon.com/eks/){:target="_blank"} that are fully bootstrapped with operational software that is needed to deploy and operate application workloads. With EKS Blueprints, you describe the configuration of a desired state of your EKS environment, such as control plane, compute plane (worker nodes), and Kubernetes add-ons, as an Infrastructure as a
Code (IaC) blueprint. Once an EKS Blueprint is configured, you can use it to stamp out consistent EKS environments across multiple AWS accounts and Regions using continuous deployment automation.

You can utilize EKS Blueprints to easily bootstrap an EKS cluster with Amazon EKS add-ons as well as a wide range of popular open-source add-ons, including Prometheus, Karpenter, Nginx, Traefik, AWS Load Balancer Controller, Fluent Bit, KEDA, Argo CD (GitOps), [Apache Spark](https://spark.apache.org/){:target="_blank"} and more. EKS Blueprints also help to
implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

## Core Concepts

Below is a high-level overview of the Core Concepts that are
incorporated into EKS Blueprints. It is assumed the reader is familiar with Git, Docker, Kubernetes, and AWS.

| Concept | Description | 
|-------------|-------------|-
| Cluster | An Amazon EKS Cluster and associated worker groups. | 
| Add-ons| Operational software that provides key functionality to support your Kubernetes applications. |      
| Teams |  A logical grouping of AWS Identity and Access Management (IAM) identities that have access to Kubernetes resources.  
| Pipeline | Continuous Delivery pipelines for deploying ```clusters``` and ```add-ons ```                                                              
| Application | An application that runs within an EKS Cluster.

### Cluster 

A ```cluster``` is an Amazon [EKS cluster](https://aws.amazon.com/eks/){:target="_blank"}. EKS
Blueprints provide customized compute options you can apply to your
clusters. The framework currently supports [Amazon Elastic Compute Cloud](https://aws.amazon.com/ec2/){:target="_blank"} (Amazon EC2) and [AWS Fargate](https://aws.amazon.com/fargate/){:target="_blank"} instances for compute plane nodes. It also supports managed and self-managed Node groups. To specify the type of compute you want to use for your cluster, you can utilize the ```managed_node_groups,self_managed_nodegroups```
or ```fargate_profiles``` Terraform variables.

See our [Node Groups](#node-groups) documentation for more detail.

### Add-ons 

```Add-ons``` allow you to configure operational tools you want to deploy into
your EKS clusters. When you configure ```add-ons``` for a ```cluster```,
those ```add-ons``` will be provisioned at deploy time by the [Terraform Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs){:target="_blank"}.
```Add-ons``` can deploy both Kubernetes specific resources and AWS resources
needed to support add-on functionality.

For example, the ```metrics-server``` add-on only deploys the Kubernetes
manifests that are needed to run the Kubernetes Metrics Server. By
contrast, the ```aws-load-balancer-controller``` add-on deploys both
Kubernetes YAML, in addition to creating resources through AWS APIs that
are needed to support the AWS Load Balancer Controller
functionality.

EKS Blueprints allow you to manage cluster add-ons directly through
Terraform (by using the Terraform Helm provider) or through GitOps
processes with [Argo CD](https://argo-cd.readthedocs.io/en/stable){:target="_blank"}. See
[Add-ons](#kubernetes-add-ons-modules) documentation section for detailed
information.

### Teams

```Teams``` allow you to configure the logical grouping of users that have
access to your EKS clusters, in addition to the access permissions they
are granted. EKS Blueprints currently supports two types
of ```teams```: ```application-team``` and ```platform-team```. ```application-team``` members
are granted access to specific namespaces, ```platform-team``` members are
granted administrative access to clusters.

See our [Teams](https://aws-ia.github.io/terraform-aws-eks-blueprints/teams/){:target="_blank"} documentation page for detailed information.
 

### Application

```Applications``` represent the actual workloads that run within a Kubernetes
cluster. The framework leverages a GitOps approach for deploying
applications onto clusters.

See [Applications](https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/argocd/#boostrapping){:target="_blank"} documentation for detailed information.

## Node Groups

The framework uses dedicated submodules for creating [AWS Managed Node Groups](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-managed-node-groups){:target="_blank"}, [Self-managed Node groups](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-self-managed-node-groups){:target="_blank"} and [Fargate profiles](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-fargate-profiles){:target="_blank"}.
These modules provide flexibility to add or remove managed/self-managed
compute node groups or Fargate profiles by simply adding or removing a
map of values to input config.
See [example](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/examples/eks-cluster-with-new-vpc){:target="_blank"}.

The ```aws-auth``` ConfigMap handled by this module allows nodes to join your
cluster, and you can also use this ConfigMap to add role-based access
control (RBAC) to AWS Identity and Access Management (IAM) users and
roles. Each node group can have a dedicated IAM role, Launch template,
and Security Group to improve the security.


### Additional IAM Roles, Users and Accounts

Access to EKS clusters using AWS IAM entities is enabled by the [AWS IAM Authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/README.md){:target="_blank"} for Kubernetes, which runs on the Amazon EKS control plane. The authenticator gets its configuration information from the ```aws-auth``` [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/){:target="_blank"}.

The following config grants additional AWS IAM users or roles an ability
to interact with your cluster. However, the best practice is to
leverage [soft-multitenancy](https://aws.github.io/aws-eks-best-practices/security/docs/multitenancy/){:target="_blank"} with the help of the [Teams](#teams) module. The Teams feature helps to manage users with dedicated Kubernetes (also known as K8s) namespaces, RBAC, IAM roles, and registers them with ```aws-auth``` to provide access to the EKS Cluster.

The example below demonstrates adding IAM Roles, IAM Users, and Accounts
using the **EKS Blueprints** module. An example of a source code file
relevant to this Guidance where those changes can be made can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/docs/node-groups.md){:target="_blank"}.

```terraform
module "eks_blueprints" {
    source = "github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform"
    # EKS CLUSTER PARAMETERS
    cluster_version = "1.24" # EKS K8s Version
    vpc_id = "<vpcid>" # Enter VPC ID
    private_subnet_ids = ["<subnet-a>", "<subnet-b>", "<subnet-c>"] # Enter Private Subnet IDs

    # List of map_roles
    map_roles = [
        {
        rolearn = "arn:aws:iam::<aws-account-id>:role/<role-name>" # The ARN of the IAM role
        username = "ops-role" # The user name within Kubernetes to map to the IAM role
        groups = ["system:masters"] # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and RoleBindings
        }
    ]

    # List of map_users
    map_users = [
        {
        userarn = "arn:aws:iam::<aws-account-id>:user/<username>" # The ARN of the IAM user to add.
        username = "opsuser" # The user name within Kubernetes to map to the IAM role
        groups = ["system:masters"] # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
        }
    ]
    map_accounts = ["123456789", "9876543321"] # List of AWS account ids
}
```

### Managed Node Groups

The example below demonstrates the minimum configuration required to
deploy a managed node group. An example of the source code file relevant
to this Guidance where those changes can be made can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/eks-cluster-with-new-vpc/main.tf){:target="_blank"}.


```hcl
# EKS MANAGED NODE GROUPS
managed_node_groups = {
    mg_4 = {
        node_group_name = "managed-ondemand"
        instance_types = ["m4.large"]
        min_size = 3
        max_size = 3
        desired_size = 3
        subnet_ids = [] # Mandatory Public or Private Subnet IDs
    }
}
```

The example below demonstrates advanced configuration options for a
managed node group with launch templates. An example of the source code
file relevant to this Guidance where those changes can be made can be
found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/eks-cluster-with-new-vpc/main.tf){:target="_blank"}.

```terraform
managed_node_groups = {
    mg_m4 = {

        # 1> Node Group configuration
        node_group_name = "managed-ondemand"
        create_launch_template = true # false will use the default launch template
        launch_template_os = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
        public_ip = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates;
        pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
        EOT

        # 2> Node Group scaling configuration
        desired_size = 3
        max_size = 3
        min_size = 3
        max_unavailable = 1 # or percentage = 20

        # 3> Node Group compute configuration
        ami_type = "AL2_x86_64" # Amazon Linux 2(AL2_x86_64), AL2_x86_64_GPU, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64
        capacity_type = "ON_DEMAND" # ON_DEMAND or SPOT
        instance_types = ["m4.large"] # List of instances used only for SPOT type
        disk_size = 50

        # 4> Node Group network configuration
        subnet_ids = [] # Mandatory - # Define private/public subnets list with comma separated ["subnet1","subnet2","subnet3"]

        # optionally, configure a taint on the compute node group:
        k8s_taints = [{key= "purpose", value="execution", "effect"="NO_SCHEDULE"}]

        k8s_labels = {
            Environment = "preprod"
            Zone = "dev"
            WorkerType = "ON_DEMAND"
            }
        additional_tags = {
            ExtraTag = "m4-on-demand"
            Name = "m4-on-demand"
            subnet_type = "private"
        }
    }
}
```

For additional EKS Node Group configuration options, please see the
following [documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/node-groups/){:target="_blank"} on GitHub.

Check the following references for additional details:

-   [Amazon EBS and NVMe on Linux
    instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html){:target="_blank"}

-   [AWS NVMe drivers for Windows
    instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/aws-nvme-drivers.html){:target="_blank"}

-   [EC2 Instance Update -- M5 Instances with Local NVMe Storage
    (M5d)](https://aws.amazon.com/blogs/aws/ec2-instance-update-m5-instances-with-local-nvme-storage-m5d/){:target="_blank"}


## IAM Policies and Roles

The IAM policy below illustrates the minimum set of permissions needed
to run EKS Blueprints, mainly focused on the list of allowed IAM
actions:
```json
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "aps:CreateAlertManagerDefinition",
            "aps:CreateWorkspace",
            "aps:DeleteAlertManagerDefinition",
            "aps:DeleteWorkspace",
            "aps:DescribeAlertManagerDefinition",
            "aps:DescribeWorkspace",
            "aps:ListTagsForResource",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateOrUpdateTags",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLifecycleHook",
            "autoscaling:DeleteTags",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLifecycleHooks",
            "autoscaling:DescribeTags",
            "autoscaling:PutLifecycleHook",
            "autoscaling:SetInstanceProtection",
            "autoscaling:UpdateAutoScalingGroup",
            "ec2:AllocateAddress",
            "ec2:AssociateRouteTable",
            "ec2:AttachInternetGateway",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateEgressOnlyInternetGateway",
            "ec2:CreateInternetGateway",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateNatGateway",
            "ec2:CreateNetworkAclEntry",
            "ec2:CreateRoute",
            "ec2:CreateRouteTable",
            "ec2:CreateSecurityGroup",
            "ec2:CreateSubnet",
            "ec2:CreateTags",
            "ec2:CreateVpc",
            "ec2:DeleteEgressOnlyInternetGateway",
            "ec2:DeleteInternetGateway",
            "ec2:DeleteLaunchTemplate",
            "ec2:DeleteNatGateway",
            "ec2:DeleteNetworkAclEntry",
            "ec2:DeleteRoute",
            "ec2:DeleteRouteTable",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteSubnet",
            "ec2:DeleteTags",
            "ec2:DeleteVpc",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeEgressOnlyInternetGateways",
            "ec2:DescribeImages",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeNatGateways",
            "ec2:DescribeNetworkAcls",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSecurityGroupRules",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcClassicLink",
            "ec2:DescribeVpcClassicLinkDnsSupport",
            "ec2:DescribeVpcs",
            "ec2:DetachInternetGateway",
            "ec2:DisassociateRouteTable",
            "ec2:ModifySubnetAttribute",
            "ec2:ModifyVpcAttribute",
            "ec2:ReleaseAddress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "eks:CreateAddon",
            "eks:CreateCluster",
            "eks:CreateFargateProfile",
            "eks:CreateNodegroup",
            "eks:DeleteAddon",
            "eks:DeleteCluster",
            "eks:DeleteFargateProfile",
            "eks:DeleteNodegroup",
            "eks:DescribeAddon",
            "eks:DescribeAddonVersions",
            "eks:DescribeCluster",
            "eks:DescribeFargateProfile",
            "eks:DescribeNodegroup",
            "eks:TagResource",
            "elasticfilesystem:CreateFileSystem",
            "elasticfilesystem:CreateMountTarget",
            "elasticfilesystem:DeleteFileSystem",
            "elasticfilesystem:DeleteMountTarget",
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeLifecycleConfiguration",
            "elasticfilesystem:DescribeMountTargetSecurityGroups",
            "elasticfilesystem:DescribeMountTargets",
            "emr-containers:CreateVirtualCluster",
            "emr-containers:DeleteVirtualCluster",
            "emr-containers:DescribeVirtualCluster",
            "events:DeleteRule",
            "events:DescribeRule",
            "events:ListTagsForResource",
            "events:ListTargetsByRule",
            "events:PutRule",
            "events:PutTargets",
            "events:RemoveTargets",
            "iam:AddRoleToInstanceProfile",
            "iam:AttachRolePolicy",
            "iam:CreateInstanceProfile",
            "iam:CreateOpenIDConnectProvider",
            "iam:CreatePolicy",
            "iam:CreateRole",
            "iam:CreateServiceLinkedRole",
            "iam:DeleteInstanceProfile",
            "iam:DeleteOpenIDConnectProvider",
            "iam:DeletePolicy",
            "iam:DeleteRole",
            "iam:DetachRolePolicy",
            "iam:GetInstanceProfile",
            "iam:GetOpenIDConnectProvider",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfilesForRole",
            "iam:ListPolicyVersions",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:TagOpenIDConnectProvider",
            "iam:TagInstanceProfile",
            "iam:TagPolicy",
            "iam:TagRole",
            "iam:UpdateAssumeRolePolicy",
            "kms:CreateAlias",
            "kms:CreateKey",
            "kms:DeleteAlias",
            "kms:DescribeKey",
            "kms:EnableKeyRotation",
            "kms:GetKeyPolicy",
            "kms:GetKeyRotationStatus",
            "kms:ListAliases",
            "kms:ListResourceTags",
            "kms:PutKeyPolicy",
            "kms:ScheduleKeyDeletion",
            "kms:TagResource",
            "logs:CreateLogGroup",
            "logs:DeleteLogGroup",
            "logs:DescribeLogGroups",
            "logs:ListTagsLogGroup",
            "logs:PutRetentionPolicy",
            "s3:CreateBucket",
            "s3:DeleteBucket",
            "s3:DeleteBucketOwnershipControls",
            "s3:DeleteBucketPolicy",
            "s3:DeleteObject",
            "s3:GetAccelerateConfiguration",
            "s3:GetBucketAcl",
            "s3:GetBucketCORS",
            "s3:GetBucketLogging",
            "s3:GetBucketObjectLockConfiguration",
            "s3:GetBucketOwnershipControls",
            "s3:GetBucketPolicy",
            "s3:GetBucketPublicAccessBlock",
            "s3:GetBucketRequestPayment",
            "s3:GetBucketTagging",
            "s3:GetBucketVersioning",
            "s3:GetBucketWebsite",
            "s3:GetEncryptionConfiguration",
            "s3:GetLifecycleConfiguration",
            "s3:GetObject",
            "s3:GetObjectTagging",
            "s3:GetObjectVersion",
            "s3:GetReplicationConfiguration",
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:PutBucketAcl",
            "s3:PutBucketOwnershipControls",
            "s3:PutBucketPolicy",
            "s3:PutBucketPublicAccessBlock",
            "s3:PutBucketTagging",
            "s3:PutBucketVersioning",
            "s3:PutEncryptionConfiguration",
            "s3:PutObject",
            "secretsmanager:CreateSecret",
            "secretsmanager:DeleteSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:PutSecretValue",
            "sqs:CreateQueue",
            "sqs:DeleteQueue",
            "sqs:GetQueueAttributes",
            "sqs:ListQueueTags",
            "sqs:SetQueueAttributes",
            "sqs:TagQueue",
            "sts:GetCallerIdentity"
        ],
        "Resource": "*"
    }
 ]
}
```
The source code can be also found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/eks-cluster-with-new-vpc/min-iam-policy.json){:target="_blank"}.

## Teams

### Introduction

EKS Blueprints provide support for onboarding and managing user teams
and configuring their cluster access. They currently support two ```Team```
types: ```application_teams``` and ```platform_teams;``` ```application_teams``` represent teams managing workloads running in cluster namespaces and ```platform_teams``` represent platform administrators who have admin access (master's group) to clusters.

You can reference the [aws-eks-teams](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-teams){:target="_blank"}
module to create your own team implementations.

### Application Team

To create an ```application_team``` for your clusters, you will need to supply
the following:

-   A team name with the options to pass map of labels

-   Map of K8s resource quotas

-   Existing IAM entities (user/roles)

-   A directory where you may optionally place any policy definitions
    and generic manifests for the team.

These manifests will be applied by EKS Blueprints and will be outside of
the team control.

{: .note }
When the manifests are applied, namespaces are not checked.
Therefore, you are responsible for namespace settings specified in IaC
*yaml* files.

Normally, resource ```kubernetes_manifest``` can only be used (```terraform
plan/apply...```) **after** the cluster has been created and the cluster
API can be accessed.

To overcome this limitation, you can add/enable ```manifests_dir``` after you
applied and created the EKS cluster first.

**Application Team Example**

Below is a source code example for ```application_team.``` A source code
example where those changes can be made for this Guidance can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-teams){:target="_blank"}.

```terraform
# EKS Application Teams

application_teams = {
    # First Team
    team-blue = {
        "labels" = {
            "appName" = "example1",
            "projectName" = "example1",
            "environment" = "example1",
            "domain" = "example1",
            "uuid" = "example1",
            }
    "quota" = {
        "requests.cpu" = "1000m",
        "requests.memory" = "4Gi",
        "limits.cpu" = "2000m",
        "limits.memory" = "8Gi",
        "pods" = "10",
        "secrets" = "10",
        "services" = "10"
        }
    manifests_dir = "./manifests"

    # Below are examples of IAM users and roles
    users = [
        "arn:aws:iam::123456789012:user/blue-team-user",
        "arn:aws:iam::123456789012:role/blue-team-sso-iam-role"
        ]
    }
    # Second Team
    team-red = {
        "labels" = {
            "appName" = "example2",
            "projectName" = "example2",
            }
        "quota" = {
            "requests.cpu" = "2000m",
            "requests.memory" = "8Gi",
            "limits.cpu" = "4000m",
            "limits.memory" = "16Gi",
            "pods" = "20",
            "secrets" = "20",
            "services" = "20"
            }
        manifests_dir = "./manifests2"
        users = [
            "arn:aws:iam::123456789012:role/other-sso-iam-role"
        ]
    }
}
```

EKS Blueprints will perform the following for every provided team
option:

-   Create a namespace

-   Register Kubernetes resource quotas

-   Register IAM users for cross-account access

-   Create a shared role for cluster access. Alternatively, an existing
    role can be supplied.

-   Register provided users/roles in the ```aws-auth``` configmap
    for ```kubectl``` and console access to the cluster and namespace.

-   (Optionally) read all additional manifests (e.g., network policies,
    OPA policies, others) stored in a provided directory, and apply
    them.


### Platform Team

To create a ```Platform Team``` for your cluster, use a ```platform_teams```
configuration. You will need to supply a team name and all users/roles.

**Platform Team Example**

Below is a source code example for ```Platform Team.``` An example of source
code where those changes can be made for this Guidance can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/aws-eks-teams){:target="_blank"}:

```terraform
platform_teams = {
admin-team-name-example = {
    users = [
    "arn:aws:iam::123456789012:user/admin-user",
    "arn:aws:iam::123456789012:role/org-admin-role"]
    }
}
```

```Platform Team``` performs the following:

-   Registers IAM users for admin level access to the EKS cluster
    (```kubectl``` and console).

-   Registers an existing role (or creates a new role) for cluster
    access with trust relationship with the provided/created role.

### Cluster Access (kubectl) 

The Terraform script execution output will contain the IAM roles for
every application (```application_teams_iam_role_arn```) or platform team
(```platform_teams_iam_role_arn```).

To update K8s cluster *kubeconfig* file contents, run the following
command:

```shell
aws eks update-kubeconfig --name ${eks_cluster_id} --region ${AWS_REGION} --role-arn ${TEAM_ROLE_ARN}
```
{: .note }
Make sure to replace the ```${eks_cluster_id}```,```${AWS_REGION}```and ```${TEAM_ROLE_ARN}``` with the
actual values.

## Kubernetes Add-ons Modules

The [kubernetes-add-ons](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/kubernetes-addons){:target="_blank"} modules
within EKS Blueprints allows the user to configure the add-ons they
would like deployed into their EKS clusters via simple **true/false** flags in the Terraform code.

The framework currently provides support for add-ons contained in the
'kubernetes-addons' source code repository [folder](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/kubernetes-addons){:target="_blank"}.


### Add-on Management

The framework provides two approaches to managing add-on configuration
for EKS clusters. They are:

1.  Via Terraform by leveraging the [Terraform Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs){:target="_blank"}.

2.  Via GitOps process with [ArgoCD](https://argo-cd.readthedocs.io/en/stable/){:target="_blank"} (used in this Guidance)


### Terraform Helm Provider

The default method for managing an add-on configuration is through
Terraform. By default, each individual add-on module will perform the
following:

1.  Create any AWS resources needed to support add-on functionality.

2.  Deploy a [Helm chart](https://helm.sh/){:target="_blank"} into the user's EKS cluster by leveraging the Terraform Helm provider.

In order to deploy an add-on with default configuration, the user
enables it through Terraform property variables as shown below. An
example of source code where those changes can be made for this Guidance
can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/addons.tf){:target="_blank"}.

```terraform
module "eks_blueprints_kubernetes_addons" {
    source ="github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/modules/kubernetes-addons"

    cluster_id = <EKS-CLUSTER-ID>

    # EKS Addons

    enable_amazon_eks_aws_ebs_csi_driver = true
    enable_amazon_eks_coredns = true
    enable_amazon_eks_kube_proxy = true
    enable_amazon_eks_vpc_cni = true

    # K8s Add-ons

    enable_argocd = true
    enable_aws_for_fluentbit = true
    enable_aws_load_balancer_controller = true
    enable_cluster_autoscaler = true
    enable_metrics_server = true
}
```

To customize the behavior of the Helm charts that are ultimately
deployed, the user can supply a custom Helm configuration. The following
demonstrates how to use the configuration, including a
dedicated *values.yaml* parameter customization file, to provide values for the Helm template. An example of a source code where these changes can be made for this Guidance can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/addons.tf){:target="_blank"}.

```terraform
enable_metrics_server = true
metrics_server_helm_config = {
    name = "metrics-server"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    chart = "metrics-server"
    version = "3.8.1"
    namespace = "kube-system"
    timeout = "1200"

    # (Optional) Example to pass values.yaml from your local repo
    values = [templatefile("${path.module}/values.yaml", {
        operating_system = "linux"
    })]
}
```

Each add-on module is configured to fetch Helm Charts from public Helm repositories and Docker images from Docker Hub/Public Amazon Elastic Container Registry (Amazon ECR) repositories. This requires an outbound Internet connection from EKS Clusters.


### Core EKS Add-ons

[Amazon EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html){:target="_blank"} provide installation and management of a curated set of features for EKS
clusters. All EKS add-ons include the latest security patches, bug fixes, and are validated to work with EKS. Amazon EKS add-ons allow you to consistently ensure that your EKS clusters are secure and stable and
reduce the amount of work that you need to do in order to install, configure, and update add-ons.

EKS currently provides support for the following managed add-ons.

| **Name**   | **Description**| 
|-------------|-------------|
| [Amazon VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html){:target="_blank"} | Native VPC networking for Kubernetes pods. | 
  [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html){:target="_blank"} | A flexible, extensible DNS server that can serve as the Kubernetes cluster DNS.
[kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html){:target="_blank"}  | Enables network communication to your pods.| 
[Amazon EBS CSI](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html){:target="_blank"} |  Manage the Amazon EBS CSI driver as an Amazon EKS add-on. |  

EKS managed add-ons can be enabled and configured as shown in the following source code:

```terraform
# EKS Addons
enable_amazon_eks_vpc_cni = true # enable VPC CNI, default is false
#Optional
amazon_eks_vpc_cni_config = {
    addon_name = "vpc-cni"
    addon_version = "v1.10.1-eksbuild.1"
    service_account = "aws-node"
    resolve_conflicts = "OVERWRITE"
    namespace = "kube-system"
    additional_iam_policies = []
    service_account_role_arn = ""
    tags = {}
 }
```
```terraform
enable_amazon_eks_coredns = true # enable EKS CoreDNS, default is false
#Optional
amazon_eks_coredns_config = {
    addon_name = "coredns"
    addon_version = "v1.8.4-eksbuild.1"
    service_account = "coredns"
    resolve_conflicts = "OVERWRITE"
    namespace = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies = []
    tags = {}
 }

enable_amazon_eks_kube_proxy = true # enable EKS Kube_proxy, default is false
#Optional
amazon_eks_kube_proxy_config = {
    addon_name = "kube-proxy"
    addon_version = "v1.21.2-eksbuild.2"
    service_account = "kube-proxy"
    resolve_conflicts = "OVERWRITE"
    namespace = "kube-system"
    additional_iam_policies = []
    service_account_role_arn = ""
    tags = {}
 }

enable_amazon_eks_aws_ebs_csi_driver = true # enable EBS CSI driver, default is false
#Optional
amazon_eks_aws_ebs_csi_driver_config = {
    addon_name = "aws-ebs-csi-driver"
    addon_version = "v1.4.0-eksbuild.preview"
    service_account = "ebs-csi-controller-sa"
    resolve_conflicts = "OVERWRITE"
    namespace = "kube-system"
    additional_iam_policies = []
    service_account_role_arn = ""
    tags = {}
 }
```

An example of the source code where similar changes can be made for this
Guidance can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/complete-kubernetes-addons/main.tf){:target="_blank"}.

## Updating Managed Add-ons

EKS will not modify any of your Kubernetes add-ons when you update a cluster to a newer Kubernetes version. As a result, it is important to upgrade EKS add-ons each time you upgrade your EKS clusters. Additional information on updating an EKS cluster can be found in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html){:target="_blank"}.

### GitOps with ArgoCD

To indicate that you would like to manage EKS add-ons through an Argo CD
GitOps tool, you should do the following:

1.  Enable the Argo CD add-on by setting the ```enable_argocd``` flag to ```true``` in the Terraform code.

2.  Specify that ArgoCD should be responsible for deploying add-ons by setting the ```argocd_manage_add_ons``` flag to ```true.``` This will prevent the individual Terraform add-on modules from deploying through Helm charts.

3.  Pass Application configuration for the add-ons repository through the ```argocd_applications``` property.

Note that the ```add_on_application``` flag in an ```Application``` configuration must be set to ```true.```

```terraform
enable_argocd = true
argocd_manage_add_ons = true
argocd_applications = {
    infra = {
        namespace = "argocd"
        path = "<path>"
        repo_url = "<repo_url>"
        values = {}
        add_on_application = true # Indicates the root add-on application.
    }
}
```

An example of source code where similar changes can be made can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"}.

**GitOps Bridge**

When managing add-ons through Argo CD, certain AWS resources may still need to be created through Terraform in order to support the add-on functionality (for example: IAM Roles and Services Accounts). Certain resource values will also need to be passed from Terraform to Argo CD through the Argo CD Application resource's values map. We refer to this concept as GitOps Bridge.

To ensure that the AWS resources needed for add-on functionality are created, you need to indicate a Terraform configuration where add-ons will be managed through Argo CD. To do so, enable selected add-ons through their boolean properties, as shown below:

```terraform
enable_metrics_server = true # Deploys Metrics Server Addon
enable_cluster_autoscaler = true # Deploys Cluster Autoscaler Addon
enable_prometheus = true # Deploys Prometheus Addon
```

An example of source code for the above settings where these changes can be made for this Guidance can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"}.

This will indicate to each add-on module that it should create the necessary AWS resources and pass the relevant values to the **Argo CD Application resource** through the Application's values map.


### Argo CD Add-on

[Argo CD](https://argo-cd.readthedocs.io/en/stable/){:target="_blank"} is a
declarative, GitOps continuous delivery tool for Kubernetes Application definitions, configurations, and environments should be declarative and version controlled and stored in a Git compatible repository. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

**Usage**

Argo CD can be deployed by enabling the add-on through a flag:
```enable_argocd = true```

**Admin Password**

Argo CD has a built-in admin user that has full access to the Argo CD server. By default, Argo CD will create a password for the admin user.

See the [Argo CD documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/){:target="_blank"} for
additional details on managing users.

**Customizing Argo CD deployment Helm Chart**

You can customize the Helm chart that deploys Argo CD using the configuration below. An example of source code where similar changes can be made for this Guidance can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"}.

```terraform
argocd_helm_config = {
    name = "argo-cd"
    chart = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version = "<chart_version>"
    namespace = "argocd"
    timeout = "1200"
    create_namespace = true
    values = [templatefile("${path.module}/argocd-values.yaml", {})]
}
```

**Bootstrapping**

The framework provides an approach to bootstrapping workloads and/or additional add-ons by leveraging the Argo CD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/){:target="_blank"} pattern.

The code example below demonstrates how you can supply information for a repository in order to bootstrap multiple workloads in a new EKS cluster. The example leverages a [sample App of Apps repository](https://github.com/aws-samples/eks-blueprints-workloads.git){:target="_blank"}.
An example of source code where these changes can be made for this Guidance can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"}.
```terraform
argocd_applications = {
    addons = {
        path = "chart"
        repo_url = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
        add_on_application = true # Indicates the root add-on application.
    }
}
```

**Managing EKS Add-ons**

A common operational pattern for EKS customers is to leverage Infrastructure as Code (IaC) to provision EKS clusters (in addition to other AWS resources), and Argo CD to manage cluster add-ons. This can present a challenge when add-ons managed by Argo CD depend on AWS
resource values that are created through a Terraform execution, such as IAM Amazon Resource Names (ARN) for an add-on that leverages IAM roles for service accounts (IRSA). The framework provides an approach to bridge the gap between Terraform and Argo CD by leveraging the Argo CD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/){:target="_blank"} pattern.

To indicate that Argo CD should manage cluster add-ons (applying add-on Helm charts to a cluster), you can set
the ```argocd_manage_add_ons``` property to ```true.``` When this flag is set, the framework will still provision all AWS resources necessary to support add-on functionality, but it will not apply Helm charts directly through the Terraform Helm provider.

Next, identify which Argo CD Application will serve as the add-on configuration repository by setting the ```add_on_application``` flag to ```true.``` When this flag is set, the framework will aggregate AWS resource values
that are needed for each add-on into an object. It will then pass that object to Argo CD through the values map of the Application resource. [See here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/modules/kubernetes-addons/locals.tf){:target="_blank"} for all the values objects that are passed to the Argo CD add-ons Application.

Sample configuration is below:
```terraform
enable_argocd = true
argocd_manage_add_ons = true
argocd_applications = {
    addons = {
        path = "chart"
        repo_url = "https://github.com/aws-samples/eks-blueprints-add-ons.git" # public repository
        add_on_application = true # Indicates the root add-on application.
        }
    }
```
The source code for the above examples where these changes can be made for this Guidance can be found [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"}.

**Private Repositories**

In order to leverage Argo CD with private Git repositories, please see related [documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.20.0/add-ons/argocd/){:target="_blank"} on GitHub.

**Complete Example**

A complete example that demonstrates the configuration of Argo CD for the management of cluster add-ons can be found in this [documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.20.0/add-ons/argocd/){:target="_blank"}.


### Apache Spark Kubernetes Operator Add-on

The ```spark-on-k8s-operator``` allows Apache Spark applications to be defined in a declarative manner and supports one-time Apache Spark applications with [SparkApplication](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/api-docs.md#sparkoperator.k8s.io/v1beta2.SparkApplication){:target="_blank"} and cron-scheduled applications with
[ScheduledSparkApplication](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/api-docs.md#sparkoperator.k8s.io/v1beta2.ScheduledSparkApplication){:target="_blank"}.

Apache Spark aims to make specifying and running Apache Spark applications as easy and idiomatic as running other workloads on Kubernetes. It uses Kubernetes custom resources for specifying, running, and surfacing the status of Apache Spark applications. For a complete reference of the custom resource definitions, please refer to the [API Definition](https://spark.apache.org/docs/latest/running-on-kubernetes.html#kubernetes-features){:target="_blank"}. For details on its design, please refer to the [design documentation](https://spark.apache.org/docs/latest/running-on-kubernetes.html){:target="_blank"}. It requires Apache Spark 2.3 and above that supports Kubernetes as a native scheduler backend.

**Usage**

[Apache Spark K8S Operator](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/tree/main/analytics/terraform/spark-k8s-operator){:target="_blank"} can be deployed by enabling the add-on with the following settings:

Basic example:

```enable_spark_k8s_operator = true```

Advanced example:

```terraform
enable_spark_k8s_operator = true
# Optional Map value
# NOTE: This block requires passing the helm values.yaml
spark_k8s_operator_helm_config = {
    name = "spark-operator"
    chart = "spark-operator"
    repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version = "1.1.19"
    namespace = "spark-k8s-operator"
    timeout = "1200"
    create_namespace = true
    values = [templatefile("${path.module}/values.yaml", {})]
}
```
A Spark Operator example source code can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/addons.tf){:target="_blank"}.

### Apache Spark History Server Add-on

Apache Spark Web UI can be enabled by the Apache Spark History Server Add-on. This add-on deploys Apache Spark History Server and fetches the Apache Spark Event logs stored in Amazon Simple Storage Service (Amazon
S3). The Apache Spark Web UI can be exposed through Ingress and Load Balancer with ```values yaml.``` Alternatively, you can port-forward on ```spark-history-server service,``` for example:
```
kubectl port-forward services/spark-history-server 18085:80 -n spark-history-server
```

**Usage**

[Apache Spark History Server](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/tree/main/modules/kubernetes-addons/spark-history-server){:target="_blank"} can
be deployed by enabling the add-on through the following example source codes:

**Basic Example**
```terraform
enable_spark_history_server = true
spark_history_server_s3a_path = "s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"
```

**Advanced Example**
<div class="language-terraform highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nx">enable_spark_history_server</span> <span class="err">=</span> <span class="kc">true</span>

<span class="c1"># IAM policy used by IRSA role. It's recommended to create a dedicated IAM policy to access your s3 bucket</span>
<span class="nx">spark_history_server_irsa_policies</span> <span class="err">=</span> <span class="p">[</span><span class="s2">"&lt;IRSA_POLICY_ARN&gt;"</span><span class="p">]</span>

<span class="c1"># NOTE: This block requires passing the helm values.yaml</span>
<span class="c1"># spark_history_server_s3a_path won't be used when you pass custom `values.yaml`. s3a path is passed via `sparkHistoryOpts` in `values.yaml`</span>

<span class="nx">spark_history_server_helm_config</span> <span class="err">=</span> <span class="p">{</span>
    <span class="nx">name</span> <span class="p">=</span> <span class="s2">"spark-history-server"</span>
    <span class="nx">chart</span> <span class="p">=</span> <span class="s2">"spark-history-server"</span>
    <span class="nx">repository</span> <span class="p">=</span> <span class="s2">"https://hyper-mesh.github.io/spark-history-server"</span>
    <span class="nx">version</span> <span class="p">=</span> <span class="s2">"1.0.0"</span>
    <span class="nx">namespace</span> <span class="p">=</span> <span class="s2">"spark-history-server"</span>
    <span class="nx">timeout</span> <span class="p">=</span> <span class="s2">"300"</span>
    <span class="nx">values</span> <span class="p">=</span> <span class="p">[</span>
        <span class="o">&lt;&lt;-</span><span class="no">EOT</span><span class="sh"></span>
        serviceAccount:
        create: <span class="s2">false</span>

        <span class="c1"># Enter S3 bucket with Spark Event logs location.</span>
        <span class="c1"># Ensure IRSA roles has permissions to read the files for the given S3 bucket</span>
        sparkHistoryOpts:
        <span class="s2">"-Dspark.history.fs.logDirectory=s3a://&lt;ENTER_S3_BUCKET_NAME&gt;/&lt;PREFIX_FOR_SPARK_EVENT_LOGS&gt;/"</span>

        <span class="c1"># Update spark conf according to your needs</span>
        sparkConf: |-
        <span class="s2">
        spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.WebIdentityTokenCredentialsProvider
        spark.history.fs.eventLog.rolling.maxFilesToRetain=5
        spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
        spark.eventLog.enabled=true
        spark.history.ui.port=18080
        </span>

        resources:
            limits:
                cpu: <span class="s2">200m</span>
                memory: <span class="s2">2G</span>
            requests:
                cpu: <span class="s2">100m</span>
                memory: <span class="s2">1G</span>
        <span class="no">EOT</span>
    <span class="p">]</span>
<span class="p">}</span>

</code></pre></div></div>

An example of the source code using the configuration settings above for Apache Spark History server can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/addons.tf){:target="_blank"}.

## Running new VPC EKS Terraform Blueprint

### Prerequisites

Ensure that you have installed the following tools in your Mac or
Windows Laptop before you start working with this module; run
**Terraform Plan** and select **Apply**:

1.  [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html){:target="_blank"}

2.  [Kubectl](https://Kubernetes.io/docs/tasks/tools/){:target="_blank"}

3.  [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli){:target="_blank"}

### Minimum IAM Policy

{: .note }
The policy resource is set as * to allow all resources. This is
not a recommended practice.

Minimum IAM policy is documented [above](#iam-policies-and-roles) and can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/eks-cluster-with-new-vpc/min-iam-policy.json){:target="_blank"}
-- it is automatically bootstrapped to EKS clusters provisioned by blueprints.

### Deployment

To provision EKS Cluster with new VPC managed components and application
workloads, you should follow these steps:

1.  Clone the repo using the command below:

```shell
git clone https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform.git
```

{:style="counter-reset:none"}
2.  Initialize Terraform:

```shell
cd examples/eks-cluster-with-new-vpc/
terraform init
```
{:style="counter-reset:none"}
3.  Verify resources to be created by this blueprint:

```shell
terraform plan
```
{:style="counter-reset:none"}
4.  Apply staged resources to AWS environment:

```shell
terraform apply
```

(Enter *yes* at the command prompt to apply or use ```terraform apply -auto-approve``` to bypass that question)

### Validation

The following command will update the *kubeconfig* on the user's machine and allow it to interact with the EKS Cluster using the ```kubectl``` client to validate the deployment.

1.  Run *update-kubeconfig* command which will update the local K8s configuration file by adding a context corresponding to newly created cluster:

```shell
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

{:style="counter-reset:none"}
2.  List all the worked nodes by running the command below:

```shell
kubectl get nodes
```
{% include image.html file="eks-provision-terraform/terraform-Figure7.png" %}

{:style="counter-reset:none"}
3.  List all the pods running in kube-system namespace:

```shell
kubectl get pods -n kube-system
```
{% include image.html file="eks-provision-terraform/terraform-Figure8.png" %}

**Cleanup**

To clean up your environment, destroy the Terraform modules in reverse order of their deployment.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC:

```shell
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules:

```shell
terraform destroy -auto-approve
```

## Running Argo CD EKS Terraform Blueprint

### Prerequisites

Ensure that the following tools are installed locally:

1.  [aws
    cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html){:target="_blank"}

2.  [kubectl](https://kubernetes.io/docs/tasks/tools/){:target="_blank"}

3.  [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli){:target="_blank"}

### Minimum IAM Policy

{: .note }
The policy resource is set as * to allow all resources, this is
not a recommended practice.

Minimum IAM policy is documented [above](#iam-policies-and-roles) and
can be found in the project repository
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/min-iam-policy.json){:target="_blank"}
-- it is automatically bootstrapped to EKS clusters provisioned by
blueprints

### Deployment

To provision EKS Cluster with Argo CD managed components and application
workloads, you should follow these steps:

1.  Clone EKS blueprints repository locally:

```shell
git clone https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform.git
```

If any customization of parameters is needed, it can be performed by
adjusting/adding parameter values in
the [main.tf](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/examples/gitops/argocd/main.tf){:target="_blank"} source code file according to the documentation above. This includes basic AWS configuration: cluster name, deployment Region, VPC Classless Inter-Domain Routing (CIDR), and Availability Zones (AZs). Additionally, EKS Kubernetes parameters: K8s API version, managed node group instance types and ranges, tags, and add-ons can also be customized.

Below is an example of such parameters with minor modifications highlighted in # comments:
```terraform
locals {
        # Optional customization: add unique postfix to cluster_name to avoid duplication or 'global'
        # role names derived from a cluster name

        name1 = basename(path.cwd)
        name = "${local.name1}-test1"
        # Customization: us-west-2 region has sufficient resources
        region = "us-west-2"

        # Customization: VPC parameters
        vpc_cidr = "10.0.0.0/16"
        azs = slice(data.aws_availability_zones.available.names, 0, 3)

        tags = {
            Blueprint = local.name
            GithubRepo ="github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform" #use forked or upstream repo
        }
    }

    #---------------------------------------------------------------
    # EKS Blueprints
    #---------------------------------------------------------------

    module "eks_blueprints" {
    source = "../../.." # location of 'parent module' in the source code hierarchy

    cluster_name = local.name

    # Customization of K8s API version
    # K8s API version for data and compute planes
    cluster_version = "1.24"

    vpc_id = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnets

    managed_node_groups = {
        mg_5 = {
            node_group_name = "managed-ondemand"
            instance_types = ["m5.large"]
            subnet_ids = module.vpc.private_subnets

            desired_size = 3
            max_size = 5
            min_size = 2
            }
        }
        tags = local.tags
    }

    # EKS Add-ons configuration
    module "eks_blueprints_kubernetes_addons" {
        # location of 'parent module' in the source code hierarchy
        source = "../../../modules/kubernetes-addons" 

        eks_cluster_id = module.eks_blueprints.eks_cluster_id
        eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
        eks_oidc_provider = module.eks_blueprints.oidc_provider
        eks_cluster_version = module.eks_blueprints.eks_cluster_version

        # Enable installation of argo-cd add-on via HELM
        enable_argocd = true

        # Set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
        argocd_helm_config = {
            set_sensitive = [
                {
                    name = "configs.secret.argocdServerAdminPassword"
                    value = bcrypt_hash.argo.id
                }
        ]
    }
}
```

{:style="counter-reset:none"}
2.  Initialize Terraform from the directory where source code is located:

```shell
cd examples/gitops/argocd
terraform init
```

{:style="counter-reset:none"}
3.  Verify resources to be created by this blueprint:

```shell
terraform plan
```

{:style="counter-reset:none"}
4.  Apply staged Terraform resources to AWS environment:

```shell
terraform apply
```


(Enter *yes* at command prompt to apply or use ```terraform apply-auto-approve``` to bypass that question).

### Validation

The following command will update the *kubeconfig* Kubernetes context
configuration file on user's machine and allow to interact with the EKS Cluster using ```kubectl``` client to validate the deployment.

1.  Run ```update-kubeconfig``` command which will update the local K8s configuration file by adding a context corresponding to newly created cluster:

```shell
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

{:style="counter-reset:none"}
2.  List out the pods running currently in the *argocd* and other K8s namespaces:


{% include image.html file="eks-provision-terraform/terraform-Figure4.png" %}


(Names of pods in different K8s namespaces reflect corresponding
deployed EKS add-ons)

{:style="counter-reset:none"}
3.  You can test access to ArgoCD Server UI by running the following commands:

```shell
kubectl port-forward svc/argo-cd-argocd-server 8080:443 -n argocd
```


> Then, open browser and navigate to <http://localhost:8080/>{:target="_blank"}. The login Username should be *admin*.
> Also, permanent Argo CD admin UI service URL can be obtained by examining services running in the ```argocd``` namespace by running the following command:

{% include image.html file="eks-provision-terraform/terraform-Figure5.png" %}

> and changing type of 'argo-cd-argocd-server' to LoadBalancer:

```shell
kubectl patch svc argo-cd-argocd-server -n argocd -p '{"spec":{"type": "LoadBalancer"}}'
```

> which can be confirmed by running the following command:

```shell
kubectl get svc -n argocd | grep argo-cd-argocd-server

argo-cd-argocd-server LoadBalancer 172.20.251.159
XXXXXXXXXXXXXXXXXXXXXXXXX.us-west-2.elb.amazonaws.com
80:31120/TCP,443:30200/TCP 12d
```

> Argo CD endpoint URL is listed as an attribute of ```argo-cd-argocd-server``` and should appear like shown in the screenshot below:

{% include image.html file="eks-provision-terraform/terraform-Figure1.png" alt="architecture" %}
<!--[](media/image1.png){width="6.03670384951881in"> height="3.840611329833771in"}-->

Figure 1 Argo CD endpoint URL

> The Argo CD admin password will be the generated password by the ```random_password``` resource, stored in AWS Secrets Manager.
>
> You can easily retrieve the password by running the following command:

```shell
aws secretsmanager get-secret-value --secret-id <SECRET_NAME> --region <REGION>
```


> Replace < SECRET_NAME > with the name of the secret name (by default it should be ```'argocd'```) and make sure to replace < REGION > with the Region where the EKS Blueprint is deployed.
>
> An example of retrieving the secret from the ```SecretString``` value is shown below:
>
> Run this command:

```shell
aws secretsmanager get-secret-value --secret-id argocd --region us-west-2
```


which should return an output like:
```json
{
    "ARN":
    "arn:aws:secretsmanager:us-west-2:XXXXXXXXX:secret:argocd-7Mz04Y",
    "Name": "argocd",
    "VersionId": "88E3BA7E-7A2E-4129-A87C-1794E1CAD627",
    "SecretString": "XXXXXXXXXXXXXXX",
    "VersionStages": [
        "AWSCURRENT"
        ],
    "CreatedDate": "2022-12-19T12:05:12.458000-08:00"
    }
```


Argo CD EKS blueprint comes with a number of pre-defined Argo CD
[applications](https://argo-cd.readthedocs.io/en/stable/core_concepts/){:target="_blank"}
configured and mapped for deployment into the local EKS cluster. Please
refer to Argo CD
[documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/){:target="_blank"}
for details on how to work with applications using that GitOps platform.
An example of such applications in Argo CD UI is shown below:

<!--[](media/image2.png){width="7.0in" height="3.675in"}-->

{% include image.html file="eks-provision-terraform/terraform-Figure2.png" %}

Figure 2 Displays how Argo CD applications are configured in an EKS
cluster

**Cleanup**

To tear down and remove all the resources created in this example, you need to ensure that all Argo CD applications are properly deleted from the cluster. This can be achieved in multiple ways:

1.  Disabling the ```argocd_applications``` configuration in the code locally and running ```terraform apply``` command again

2.  Deleting the apps using ```argocd``` [cli](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-argocd){:target="_blank"} or UI

The example below shows how the Argo CD applications are configured and
managed by that platform in an EKS cluster that can be deleted by
selecting the **Delete** buttons:

<!--[](media/image3.png){width="7.0in" height="3.276388888888889in"}-->

{% include image.html file="eks-provision-terraform/terraform-Figure3.png" %}

Figure 3 Displays how Argo CD applications can be deleted from the EKS cluster

{:style="counter-reset:none"}
3.  Deleting the apps using ```kubectl``` following [ArgoCD guidance](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-kubectl){:target="_blank"}

After application-level cleanup, you can delete the Terraform provisioned resources as follows:

```shell
terraform destroy -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks_blueprints -auto-approve
# Finally destroy all additional resources not provisioned by above TF modules
terraform destroy -auto-approve
```

## Running Apache Spark on EKS Terraform Blueprint

### Prerequisites

Ensure that the following tools are installed locally:

1.  [aws
    cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html){:target="_blank"}

2.  [kubectl](https://kubernetes.io/docs/tasks/tools/){:target="_blank"}

3.  [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli){:target="_blank"}

### Minimum IAM Policy

{: .note }
The policy resource is set as * to allow all resources, this is
not a recommended practice.

Minimum IAM policy is documented [above](#iam-policies-and-roles) and can be found
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/examples/min-iam-policy.json){:target="_blank"}
-- it is automatically bootstrapped to EKS clusters provisioned by
blueprint

### Deployment

To provision the EKS Cluster with Apache Spark and Apache Spark History
server components and application workloads, follow these steps:

1.  Clone EKS blueprints [data on EKS](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform){:target="_blank"} source code repository (where Apache Spark EKS add-on blueprint is hosted) locally:

```shell
git clone https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform.git
```

{:style="counter-reset:none"}
2.  Initialize Terraform:

```shell
cd analytics/terraform/spark-k8s-operator
terraform init
```

{:style="counter-reset:none"}
3.  Verify AWS and EKS K8s resources to be created by this blueprint

```shell
terraform plan
```

{:style="counter-reset:none"}
4.  Apply staged resources to AWS environment

```shell
terraform apply
```

(Enter *yes* at command prompt to apply)

### Validation

The following command will update the ```kubeconfig``` client configuration file on the user's machine and allow it to interact with the EKS Cluster
using ```kubectl``` to validate the deployment.

Run ```update-kubeconfig``` command:

```shell
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

**Running Test Apache Spark Job from a Driver pod**

1.  First, you need to create a Kubernetes  Service account that will have a role that allows driver pods to create pods and services under the default [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/){:target="_blank"} policiesas explained in the
[Documentation](https://spark.apache.org/docs/latest/running-on-kubernetes.html#cluster-mode){:target="_blank"}

An example of such commands for 'default' namespace is shown below:

```shell
kubectl create serviceaccount spark
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
```

You can verify whether necessary permissions were granted to the created Service account by running the following command:

```shell
kubectl auth can-i create pods -n default --as system:serviceaccount:default:spark
```

which should produce an output:```yes```

{:style="counter-reset:none"}
2.  Now we need to determine a URL of Kubernetes master node to use later for Spark job submission. The command below returns a URL of master node:

```shell
kubectl cluster-info
```


that should produce an output including entry like (partially masked for privacy):

```console
Kubernetes control plane is running at
https://XXXXXXXXXXXXXXXXXXXXXXXXX.gr7.us-east-2.eks.amazonaws.com
```

{:style="counter-reset:none"}
3.  With API endpoint determined and service accounts configured, we can run a test Spark job using an instance of the apache/spark image. The command below will create a pod instance from which we can launch test jobs.

*Creating a pod to deploy a cluster in client mode, Apache Spark applications is sometimes referred to as deploying a "jump," "edge," or "bastian" pod. It's a variant of deploying a [Bastion Host](https://en.wikipedia.org/wiki/Bastion_host){:target="_blank"}, where high-value or sensitive resources run in one environment and the bastion serves as a proxy.*

An example command below creates a jump pod using the Spark driver container based on the 'apache/spark' container image that is using
the previously created 'spark' service account:

```shell
kubectl run spark-test-docker --overrides='{"spec" {"serviceAccount":"spark"}}' -it --image=apache/spark -- /bin/bash
```

The ```kubectl``` command creates a deployment and driver pod, and will drop into its *bash* shell when the pod becomes available. *The remainder of the commands in this section will use this shell.*

{:style="counter-reset:none"}
4.  Apache's Spark image distribution contains an example program that can be used to calculate the number [Pi](https://en.wikipedia.org/wiki/Pi){:target="_blank"}. Since it works without any input, it is useful for running tests. We can check that the Spark cluster is configured correctly by submitting this application to the cluster. Apache Spark commands are submitted using ```spark-submit utility.``` In the container images created above*,* ```spark-submit``` can be found in the */opt/spark/bin folder.*

```spark-submit``` command options can be quite complicated, please see [documentation](https://spark.apache.org/docs/latest/running-on-kubernetes.html#cluster-mode){:target="_blank"} for all option values . For that reason, let's configure a set of environment variables with important runtime parameters. *While we define these directly here, in Spark applications they can be injected from a ConfigMap or as part of the pod/deployment manifest:*

```shell
# Define environment variables with K8s namespace, accounts and auth parameters
export SPARK_NAMESPACE=default
export SA=spark
export K8S_CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
export K8S_TOKEN=/var/run/secrets/kubernetes.io/serviceaccount/token

# Docker runtime image and driver pod name
export DOCKER_IMAGE=apache/spark
export SPARK_DRIVER_NAME=spark-test-pi
```

{:style="counter-reset:none"}
5.  The example command below submits Spark job to the cluster referenced by --master option. It will deploy in "*cluster*" mode and **reference** the ```spark-examples``` JAR included with the specified container image. We tell Apache Spark which program within the JAR to execute by defining the --class option. In this case, we wish to run the ```org.apache.spark.examples.SparkPi``` Java class:

```shell
# spark-submit command

/opt/spark/bin/spark-submit --name $SPARK_DRIVER_NAME \
    --master k8s://https://XXXXXXXXXXXXXXXXXXX.gr7.us-east-2.eks.amazonaws.com:443 \
    --deploy-mode cluster \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.driver.pod.name=$SPARK_DRIVER_NAME \
    --conf spark.kubernetes.authenticate.subdmission.caCertFile=$K8S_CACERT \
    --conf spark.kubernetes.authenticate.submission.oauthTokenFile=$K8S_TOKEN \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=$SA \
    --conf spark.kubernetes.namespace=$SPARK_NAMESPACE \
    --conf spark.executor.instances=2 \
    --conf spark.kubernetes.container.image=$DOCKER_IMAGE \
    --conf spark.kubernetes.container.image.pullPolicy=Always \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.3.2.jar 100000
```


*NOTES:*

-   *The Kubernetes API is available within the cluster within the
    ```default``` namespace and should be used in the ```master``` option. If
    Kubernetes DNS is available, API can be accessed via namespace URL
    (```https://kubernetes.default:443``` to be used the example above).
    The ```k8s://https://```form of the URL - this is **not** a
    typo, the ``k8s://`` prefix is how Spark determines the provider
    type.*

-   *The ```local://``` path of the ```jar``` above references location of the
    file in the executor container image, not on the jump pod that we
    used to submit the job. Both the driver and executors rely on that
    path in order to find the program implementation and start Spark
    tasks.*

{:style="counter-reset:none"}
6.  If you watch the pod list while the job is running using ```kubectl get pods,``` you should see a "driver" pod initialized with the name provided in the ```SPARK_DRIVER_NAME``` option. It will launch executor pods that actually perform the work while staying in "Running" status and get deleted upon job completion . When the Spark Job finishes running, the driver pod changes into "Completed" status. You can review status of these pods and retrieve Spark job results from the pod logs using command like:

```shell
# monitor driver and executor pods initialized by Spark job submission:

kubectl get pods -n default -w
```

Which should give an output like:

{% include image.html file="eks-provision-terraform/terraform-Figure6.png" %}

You can also retrieve results of Spark Job execution running command like:

```shell
# Retrieve the results of the program from the cluster

kubectl logs -f $SPARK_DRIVER_NAME
```


Toward the end of the "driver" pod log, you should see a result line similar to example shown below:

```console
23/02/21 02:05:31 INFO TaskSetManager: Finished task 99998.0 in stage 0.0 (TID 99998) in 27 ms on 10.1.142.42 (executor 2) (99999/100000)
23/02/21 02:05:31 INFO TaskSetManager: Finished task 99999.0 in stage 0.0 (TID 99999) in 25 ms on 10.1.46.210 (executor 1) (100000/100000)
23/02/21 02:05:31 INFO TaskSchedulerImpl: Removed TaskSet 0.0, whose tasks have all completed, from pool
23/02/21 02:05:31 INFO DAGScheduler: ResultStage 0 (reduce at SparkPi.scala:38) finished in 153.114 s
23/02/21 02:05:31 INFO DAGScheduler: Job 0 is finished. Cancelling potential speculative or zombie tasks for this job
23/02/21 02:05:31 INFO TaskSchedulerImpl: Killing all running tasks in stage 0: Stage finished
23/02/21 02:05:31 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 153.531012 s
**Pi is roughly 3.1416237160019795**
```

**Pre-requisites for running Kubernetes Spark Application examples**

There are examples for Apache Spark Applications configurations that can
be launched directly as K8s objects
located [here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/tree/main/analytics/terraform/spark-k8s-operator/examples){:target="_blank"}.
Every *yaml* file in the *examples* folder has pre-requisite
requirements mentioned at the top of the file in the commented section.
See an example for this configuration
[here](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/blob/main/analytics/terraform/spark-k8s-operator/examples/benchmark/tpcds-benchmark-1t.yaml){:target="_blank"}.

{: .note }
This example requires the following prerequisites before executing
the jobs:

1.  Ensure ```spark-team-a``` name space exists

2.  replace ```< ENTER_YOUR_BUCKET >``` with your bucket name

3.  Ensure you run
    ```"analytics/spark-k8s-operator/spark-samples/tpcds-benchmark-data-generation-1t.yaml"```
    to generate the INPUT data in the Amazon S3 bucket and update INPUT argument ```("s3a://<ENTER_YOUR_BUCKET>/TPCDS-TEST-1T/catalog_sales/")``` path in the below yaml

Please follow the instructions (for example: create an Amazon S3 bucket with necessary permissions and specify its name in the section of the application configuration file) in order to run the examples using ```kubectl apply -f <descriptor>.yaml``` syntax

**Cleanup**

To clean up your environment, first delete all Apache Spark applications
and then destroy the Terraform modules in reverse order of their
deployment.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC as
follows:
```shell
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above
modules:

```shell
terraform destroy -auto-approve
```

## Support and Troubleshooting

### Support & Feedback

EKS Terraform Blueprints is an
[Open-Source](https://opensource.com/resources/what-open-source){:target="_blank"} project
maintained by AWS Solution Architects. It is not part of an AWS Service
and support is provided with best-effort by AWS Solution Architects and
the EKS Blueprints community.

To post feedback, submit feature ideas or report bugs, you can use the [Issues section](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform/issues){:target="_blank"} of
the project GitHub repository (and the link on the Guidance).

If you are interested in contributing to EKS Blueprints, you can follow the [Contribution guide.](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform/blob/main/CONTRIBUTING.md){:target="_blank"}

### Version Requirements

This version of EKS Blueprint requires the following version of core tools

| **Name**  | **Version**| 
|-----------|------------|
|[terraform](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_terraform){:target="_blank"}  | >= 1.0.0 | 
|[aws](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_aws){:target="_blank"} | >= 3.72
|[helm](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_helm){:target="_blank"} | >= 2.4.1
|[http](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_http){:target="_blank"} | 2.4.1
|[kubectl](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_kubectl){:target="_blank"} | >= 1.14
|[kubernetes](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_kubernetes){:target="_blank"} | >= 2.10
|[local](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#requirement_local){:target="_blank"} |  >= 2.1

and Service providers:

| **Name**  | **Version**| 
|-----------|------------|
|[aws](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#provider_aws){:target="_blank"} | >= 3.72
|[http](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#provider_http){:target="_blank"} | 2.4.1
|[kubernetes](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#provider_kubernetes){:target="_blank"} |  >= 2.10


### Customization

EKS Terraform Blueprints are highly customizable. Versions of core
components from Kubernetes API version, to AWS services parameters such
as: target AWS region, VPC CIDR range, name, AMI instance type, and
range of node pool for compute plane can all be customized.

This Guidance has been successfully tested with values of those parameters used in the sample code in the GitHub [repository](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform){:target="_blank"} for “New VPC” and “Argo CD Add-on” and this [repository](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-data-apps-amazon-elastic-kubernetes-service-using-terraform){:target="_blank"} for Spark Add-on use cases, with an exception of ```local.region``` parameter that was set to the AWS Region with the most available resources.

You may specify different values for customization parameters. Be aware
of your AWS environment topology, resources, and use values that make
sense for that environment.

A full list of Terraform
[input](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#inputs){:target="_blank"}
and
[output](https://github.com/aws-solutions-library-samples/guidance-for-automated-provisioning-of-amazon-elastic-kubernetes-service-using-terraform#outputs){:target="_blank"}
parameters that are used for Blueprint customization can be found in the
Project repository.

### Troubleshooting

Terraform is a command-line tool that generates extensive logs when
commands are executed. If Blueprint deployment fails for some reason
(usually during execution of terraform apply command, see
[above](#running-argo-cd-eks-terraform-blueprint) for details) you can
find detailed error messages in the log displayed on your console such
as shown below:
```console
Error: failed creating IAM Role
(eks-cluster-with-new-vpc-aws-node-irsa): EntityAlreadyExists: Role with
name eks-cluster-with-new-vpc-aws-node-irsa already exists.
│  status code: 409, request id: c29d95fb-b206-4121-bdda-953be12209ef

│   with
module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role.irsa[0],
│   on ../../modules/irsa/main.tf line 35, in resource "aws_iam_role" "irsa":

│   35: resource "aws_iam_role" "irsa" {

│ Error: unexpected EKS Add-On (eks-cluster-with-new-vpc:coredns) state
returned during creation: timeout while waiting for state to become
'ACTIVE' (last state: 'DEGRADED', timeout: 20m0s)
│ [WARNING] Running terraform apply again will remove the kubernetes
add-on and attempt to create it again effectively purging previous
add-on configuration

│   with module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].aws_eks_addon.coredns[0],
│   on ../../modules/kubernetes-addons/aws-coredns/main.tf line 12, in resource "aws_eks_addon" "coredns":
│   12: resource "aws_eks_addon" "coredns" {

│Error: error creating IAM Policy eks-cluster-with-new-vpc-aws-ebs-csi-driver-irsa: EntityAlreadyExists: A policy called eks-cluster-with-new-vpc-aws-ebs-csi-driver-irsa already exists. Duplicate names are not ||   allowed.
│   status code: 409, request id: a1d15c7f-24fe-4e1f-966a-c0b97191d5a3

│ with
module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_iam_policy.aws_ebs_csi_driver[0],
│ on ../../modules/kubernetes-addons/aws-ebs-csi-driver/main.tf line 91,
in resource "aws_iam_policy" "aws_ebs_csi_driver":
│ 91: resource "aws_iam_policy" "aws_ebs_csi_driver" {

```
Log files usually point to a Terraform module name and line of its
script where error occurred, allowing you to examine the specified
parameters and make necessary changes, then try deployment again.

In the example above, an EKS cluster named ```eks-cluster-with-new-vpc``` was
deployed to another Region, with generated IAM roles and policies
objects based on that cluster name that are "globally" scoped. That
caused the errors above. The errors were fixed by changing the value
assigned to the parameter ```cluster_name = "${local.cluster_name1}-test1"```
in the ```main.tf locals``` module. This ensured that the cluster, the related
role, and the policy names would be unique.
