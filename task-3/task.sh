#!/bin/bash

mkdir -p "./files/"

while read file_name; do
    touch ./files/$file_name
done < prilog.txt


our_files=`ls files`
for file in $our_files
do
  name=''
  extension=''

  c_file=$(echo "$file" | tr -d '\r')
  name=$(echo "$file" | awk -F '.' '{ print $1 }' | tr -d '\r')
  extension=$(echo "$file" | awk -F '.' '{ print $2 }' | tr -d '\r') 

  if [[ ! "${name:1}" =~ ^[0-9a-fA-F]+$ || "$extension" != "kod" ]]; then
      echo "Not hexadecimal or extension is not kod"
      echo "$file"
  else
      # echo ${name:7:1} #GET G
      # echo ${name:5:1} #GET E
      G="${name:7:1}"
      E="${name:5:1}"

      if (( 16#${name:7:1} % 2 == 0 )); then
        # mv to G0/E0
        mkdir -p "./files/${G}0/${E}0"
        mv "./files/$file" "./files/${G}0/${E}0/$c_file"

      else
        # mv to X0/E0
        # X = G - 1
        char="${name:7:1}"
        X=$((16#$char - 1))
        X_hex=$(printf "%x" $X)

        mkdir -p "./files/${X_hex}0/${E}0"
        mv "./files/$file" "./files/${X_hex}0/${E}0/$c_file"
      fi
  fi

done