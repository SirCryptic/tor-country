#!/bin/bash
# Shell script to change Tor exit node country

IFS=$'\n'
PS3="Chose the correct path: "

get_country_code() {
    country_data=$(grep -i "$1" data.csv)
    if [ "$country_data" ]
    then
    
        if [ $(echo "$country_data" | wc -l) -eq 1 ]
        then
            country_code=$(echo $country_data | rev | cut -d "," -f1 | rev)
        else
            echo -e "Multiple countries matched:\n$country_data"
            return 1
        fi
        
    else
        echo "Could not find country."
        return 1
    fi
    
    echo "Country code: $country_code"
    return 0
}

get_torrc_path() {
    torrc_path=$(find / -type f -iwholename "*/Tor/torrc" 2>/dev/null)
    if [ "$torrc_path" ]
    then
        
        if [ $(echo "$torrc_path" | wc -l) -gt 1 ]
        then
            select path in $torrc_path
            do
                if [ "$path" ]
                then
                    torrc_path=$path
                    break
                fi
            done
        fi
        
    else
        echo "The torrc file was not found."
        return 1
    fi
    
    echo "Path: $torrc_path"
    return 0
}

change_country() {
    if [ -r $torrc_path ] && [ -w $torrc_path ]
    then
        grep -v "^ExitNodes" $torrc_path > temp
        echo "ExitNodes {$country_code}" >> temp
        mv temp $torrc_path
    else
        echo "You don't have permissions to read or write the torrc file."
        return 1
    fi
    
    echo "You might need to restart Tor to apply the changes."
    return 0
}

if [ $# -eq 1 ]
then
    country=$1
else
    read -p "Country name to search: " country
fi

get_country_code $country && get_torrc_path && change_country