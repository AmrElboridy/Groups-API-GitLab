#!/bin/bash
Type=("db" "linux" "openshift" "unix")
site=("smart" "zahraa")
zone=("production" "staging")
department=("revenue" "networks")
hostname=machine-name
privateToken=
urlgroup="https://gitlab.brightskiesinc.com/api/v4/groups/" 
urlproject="https://gitlab.brightskiesinc.com/api/v4/projects/"

for i in "${Type[@]}"
do
    echo "$i"
    echo '{"path": "'"$i"'", "name": "'"$i"'" }' 
    curl --request POST --header "PRIVATE-TOKEN: $privateToken" \
     --header "Content-Type: application/json" \
     --data '{"path": "'"$i"'", "name": "'"$i"'" }' \
     --url "$urlgroup" > structure.out
    type_group_id="`cat structure.out | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`"
    echo "$type_group_id"
    for j in "${site[@]}"
    do
	echo "$i/$j"
	echo '{"path": "'"$i/$j"'", "name": "'"$j"'" }'
	curl --request POST --header "PRIVATE-TOKEN: $privateToken" \
        --header "Content-Type: application/json" \
        --data '{"path": "'"$j"'", "name": "'"$j"'", "parent_id":"'"$type_group_id"'" }' \
	--url "$urlgroup" > structure.out
        site_group_id="`cat structure.out | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`"
	echo "$site_group_id"
        for k in "${zone[@]}"
        do
            echo "$i/$j/$k"
	    curl --request POST --header "PRIVATE-TOKEN: $privateToken" \
            --header "Content-Type: application/json" \
            --data '{"path": "'"$k"'", "name": "'"$k"'", "parent_id":"'"$site_group_id"'" }' \
	    --url "$urlgroup" > structure.out
            zone_group_id="`cat structure.out | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`"
	    echo "$zone_group_id"
            for l in "${department[@]}"
            do
                echo "$i/$j/$k/$l"
		curl --request POST --header "PRIVATE-TOKEN: $privateToken" \
                --header "Content-Type: application/json" \
                --data '{"path": "'"$l"'", "name": "'"$l"'", "parent_id":"'"$zone_group_id"'"  }' \
		--url "$urlgroup" > structure.out
                department_group_id="`cat structure.out | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`"
		echo "$department_group_id"

		curl --request POST --header "PRIVATE-TOKEN: $privateToken" \
                --header "Content-Type: application/json" \
                --data '{"name": "'"$hostname"'", "description": "'"$hostname"'", "path": "new_project", "initialize_with_readme": "true" , "namespace_id": "'"$department_group_id"'"}' \
                --url "$urlproject"
            done

        done
    done

done
