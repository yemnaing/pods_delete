Force Delete Evicted / Terminated Pods in Kubernetes
ByJosphat Mutai-August 25, 202016330

ShareFacebookTwitterPinterestWhatsApp
You can support us by downloading this article as PDF from the Link below.Download the guide as PDF
In this short tutorial we will look at how you can delete evicted or terminated Pods in a Kubernetes Cluster. There are many reasons you’ll find some Pods in Evicted and Terminated State. For eviction it is often as a result of resources pressure in the worker nodes or application error. Termination could be as result of scaling down an application or deploying new release of application where old Pods are terminated after.


The kubelet service which runs in every node in the cluster is responsible for Pod eviction. The order of pods eviction is:

Best Effort – QoS class
Burstable pods using more resources than its request of the starved resource.
Burstable pods using less resources than its request of the starved resource.
You can get list of Pods in a namespace stuck in Terminated or Evicted State by running the following command:

kubectl get pods -n namespace | egrep -i 'Terminated|Evicted'
Force Delete Evicted / Terminated Pods in Kubernetes
You can delete these pods in various ways.


Using kubectl and Bash native commands
These are bash commands with filtering you’ll run to force deletion of Pods in Namespace that are stuck in the Evicted or Terminated State.

# Define namespace
namespace="mynamespace"

# Get all pods in Terminated / Evicted State
epods=$(kubectl get pods -n ${namespace} | egrep -i 'Terminated|Evicted' | awk '{print $1 }')

# Force deletion of the pods

for i in ${epods[@]}; do
  kubectl delete pod --force=true --wait=false --grace-period=0 $i -n ${namespace}
done

Confirm if there are still pods in this state.

kubectl get pods -n ${namespace} | egrep -i 'Terminated|Evicted'

Deleting all evicted and terminated pods from all namespaces:

kubectl get pods --all-namespaces | egrep -i  'Evicted|Terminated' | awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod --force=true --wait=false --grace-period=0


Delete all containers in ImagePullBackOff state from all namespaces – Bonus:


kubectl get pods --all-namespaces | grep 'ImagePullBackOff' | awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod


Delete all containers in ImagePullBackOff or ErrImagePull state from all namespaces – Bonus:

kubectl get pods --all-namespaces | grep -E 'ImagePullBackOff|ErrImagePull|Evicted' | awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod


Using kubectl filters and jq


You can also filter kubectl command output and pipe to jq to get specific columns.

First install jq command:

--- Ubuntu / Debian ---
$ sudo apt update && sudo apt install jq

--- CentOS/Fedora ---
$ sudo yum -y install epel-release
$ sudo yum -y install jq

--- RHEL ---
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq
chmod +x jq
sudo mv jq /usr/local/bin
Then remove Evicted Pods with the command:


kubectl get pods --all-namespaces -o json | jq '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c
Stay connected for more interesting guides on containers. Also check other relevant articles in our website.

