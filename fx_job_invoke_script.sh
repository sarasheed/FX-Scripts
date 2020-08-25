#!/bin/bash
# Begin

FX_USER=$1
FX_PWD=$2
FX_JOBID=$3
REGION=$4
FX_ENVID=$5
FX_PROJECTID=$6
 
runId=$(curl --location --request --header -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" "https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION}&env=${FX_ENVID}&projectId=${FX_PROJECTID}" | jq -r '.["data"]|.id')

echo "runId =" $runId
if [ -z "$runId" ]
then
	  echo "RunId = " "$runId"
          echo "Invalid runid"
	  echo $(curl --location --request --header -X POST -d '{}' -u "${FX_USER}":"${FX_PWD}" 'https://cloud.fxlabs.io/api/v1/runs/job/${FX_JOBID}?region=${REGION}&env=${FX_ENVID}&projectId=${FX_PROJECTID}' | jq -r '.["data"]|.id')
          exit 1
fi


taskStatus="WAITING"
echo "taskStatus = " $taskStatus



while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
	 do
		sleep 5
		 echo "Checking Status...."

		passPercent=$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/${runId} | jq -r '.["data"]|.ciCdStatus') 
                        
			IFS=':' read -r -a array <<< "$passPercent"
			
			taskStatus="${array[0]}"			

			echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Time Taken =" "${array[4]}" " Run =" "${array[5]}"
			
				

		if [ "$taskStatus" == "COMPLETED" ];then
            echo "------------------------------------------------"
			echo  "Run detail link https://cloud.fxlabs.io${array[7]}"			
			echo "-----------------------------------------------"
                        echo "Array 1 ${array[1]}"
			echo "Array 2 ${array[2]}"
			echo "Array 3 ${array[3]}"
			echo "Array 4 ${array[4]}"
			echo "Array 5 ${array[5]}"
			echo "Array 6 ${array[6]}"
			echo "Array 7 ${array[7]}"
			
                	echo "Job run successfully completed"
                        exit 0

                fi
	done

if [ "$taskStatus" == "TIMEOUT" ];then 
echo "Task Status = " $taskStatus
 exit 1
fi

echo "$(curl -k --header "Content-Type: application/json;charset=UTF-8" -X GET -u "${FX_USER}":"${FX_PWD}" https://cloud.fxlabs.io/api/v1/runs/${runId})"
exit 1

return 0












