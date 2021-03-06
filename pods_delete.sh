# Define namespace
namespace="mynamespace"

# Get all pods in Terminated / Evicted State
epods=$(kubectl get pods -n ${namespace} | egrep -i 'Terminated|Evicted' | awk '{print $1 }')

# Force deletion of the pods

for i in ${epods[@]}; do
  kubectl delete pod --force=true --wait=false --grace-period=0 $i -n ${namespace}
done
