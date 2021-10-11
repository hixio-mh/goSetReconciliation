#!/usr/bin/env bats

@test "Add Elements To One Node Only & Check For Successfull Sync" {
  ports="$(docker ps | awk '/set/ {print $1}' | xargs -I {} docker port {} 8080 | sed ':a;N;$!ba;s/\n/,/g' | sort)"
	IFS=', ' read -r -a ports_list <<< "$ports"

	node1="${ports_list[0]}"
	node2="${ports_list[1]}"
	
	response="$(curl -sS -i http://$node1/set/add --data '{"value": "1"}' | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -i http://$node1/set/add --data '{"value": "2"}' | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -i http://$node1/set/add --data '{"value": "3"}' | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]

	response="$(curl -sS -X GET http://$node1/set/list)" && [ "$response" == "[1,2,3]" ]
	response="$(curl -sS -X GET http://$node2/set/list)" && [ "$response" == "[]" ]

	# response="$(curl -sS -X GET http://$node1/sync | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -i -X GET http://$node1/set/sync | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -X GET http://$node1/set/list)" && [ "$response" == "[1,2,3]" ]
	response="$(curl -sS -X GET http://$node2/set/list)" && [ "$response" == "[1,2,3]" ]
}
