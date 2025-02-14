#!/usr/bin/env bats

@test "Add Different Elements To Nodes & Check For Successfull Sync" {
  ports="$(docker ps | awk '/set/ {print $1}' | xargs -I {} docker port {} 8080 | sed ':a;N;$!ba;s/\n/,/g' | sort)"
	IFS=', ' read -r -a ports_list <<< "$ports"

	node1="${ports_list[0]}"
	node2="${ports_list[1]}"

	response="$(curl -sS -i http://$node1/set/add --data '{"values": [1,2,6]}' | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -i http://$node2/set/add --data '{"values": [1,2,3,4,5]}' | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]

	response="$(curl -sS -X GET http://$node1/set/list)" && [ "$response" == "[1,2,6]" ]
	response="$(curl -sS -X GET http://$node2/set/list)" && [ "$response" == "[1,2,3,4,5]" ]

	response="$(curl -sS -i http://$node1/set/sync | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -i http://$node2/set/sync | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]

	response="$(curl -sS -X GET http://$node1/set/list)" && [ "$response" == "[1,2,6,3,4,5]" ]
	response="$(curl -sS -X GET http://$node2/set/list)" && [ "$response" == "[1,2,3,4,5,6]" ]
}

@test "Set Debug Clear" {
  ports="$(docker ps | awk '/set/ {print $1}' | xargs -I {} docker port {} 8080 | sed ':a;N;$!ba;s/\n/,/g' | sort)"
	IFS=', ' read -r -a ports_list <<< "$ports"

	node1="${ports_list[0]}"
	node2="${ports_list[1]}"

	response="$(curl -sS -i http://$node1/set/debug/clear | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]
	response="$(curl -sS -i http://$node2/set/debug/clear | awk ' /HTTP/ {print $2}')" && [ "$response" == "200" ]

	response="$(curl -sS -X GET http://$node1/set/list)" && [ "$response" == "[]" ]
	response="$(curl -sS -X GET http://$node2/set/list)" && [ "$response" == "[]" ]
}
