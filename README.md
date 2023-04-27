# AWS EKS Cluster with EFS volume

This repository contains code and instructions for deploying an AWS EKS cluster with EFS volume.

## Prerequisites

To use this repository, you need to have the following:

- An AWS account with appropriate permissions to create EKS clusters and EFS volumes.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) version 2.11.3 or higher installed on your local machine.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed on your local machine.
- [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) installed on your local machine.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed on your local machine.

## Deployment

Before deploying make sure you setup the AWS profile, we will need it for the TF provosioning:
```bash
export AWS_PROFILE=<PROFILE>
```
To deploy the EKS cluster with EFS volume, follow the steps below:
- Open a terminal and provision the infrastructure with Terraform by running the following commands:
```bash
cd terraform

terraform init
terraform apply
```
- Next we need to configure your computer to communicate with the newly created cluster by running the following script:
```bash
sh scripts/access-cluster.sh 
```

- We need to create an [IAM OIDC](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) provider for the cluster. We can check first if it exists: 
```bash
oidc_id=$(aws eks describe-cluster --region eu-west-2 --name aws-k8s-efs-cluster --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
```
If the following command doesn't output anythig it means it doesn't exist so we need to install it:
```bash
sh scripts/oidc-provider-install.sh 
```
If you rerun the previous command you should have an output now. 

### Deploying the K8s objects

- Log into the AWS Console and find the newly created EFS File system. Copy the file system ID (should look like this `fs-xxxxx`) and paste it in the following files: 
    - `k8s\dp\sc` under `fileSystemId`
    - `k8s\sp\pv` under `volumeHandle`
- Provision the ecr driver:
  ```sh
  k apply -f k8s/public-ecr-driver.yaml   
  ```
### At this point we can either provision the volume static or dynamic.


<b>For static provisioning we will use the sp directory:</b>
```sh
k apply -f k8s/sp/pv.yaml  

k get pv

NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
efs-pv   5Gi        RWO            Retain           Available                                   5s
```
we can now setup the rest of the objects:
```sh
k apply -f k8s/sp
```
The following should happen
```bash 
k get pv 
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
efs-pv   5Gi        RWO            Retain           Bound    default/efs-claim                           82s

k get pvc
NAME        STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-claim   Bound    efs-pv   5Gi        RWO                           63s

k get pods
NAME      READY   STATUS    RESTARTS   AGE
efs-app   1/1     Running   0          84s
```
Test the pod with the following command:
```bash
kubectl exec -ti efs-app -- tail -f /data/out.txt

Fri Apr 21 18:21:39 UTC 2023
Fri Apr 21 18:21:41 UTC 2023
Fri Apr 21 18:21:43 UTC 2023
Fri Apr 21 18:21:45 UTC 2023
```

<b>For dynamic provisioning we will use the dp directory:</b>
```bash 
k apply -f k8s/dp/sc.yaml 

k get sc
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
efs-sc          efs.csi.aws.com         Delete          Immediate              false                  29s
```
We can now setup the rest of the objects:
```bash 
k apply -f k8s/dp 

k get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-claim-1   Bound    pvc-64db2ef3-1b56-485d-a4f3-9967bb4bdd75   5Gi        RWX            efs-sc         17s

k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
pvc-64db2ef3-1b56-485d-a4f3-9967bb4bdd75   5Gi        RWX            Delete           Bound    default/efs-claim-1   efs-sc                  34s

k get pods
NAME        READY   STATUS    RESTARTS   AGE
efs-app-1   1/1     Running   0          56s
```

In the EFS File system should now be a new Access point.

After finishing make sure to delete everything
```bash
tf destroy
```

REFERENCE https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html


    