#!/bin/bash

# Author: Luis Ponce (aka lushop22)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Saliendo...\n${endColour}"

	tput cnorm; exit 1
}

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}




function helpPanel(){
	echo -e "\n${redColour}[!] Uso: latexScript\n${endColour}"
	for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
	echo -e "\n\n\t${grayColour}[-t]${endColour}${yellowColour} Tipo de template a usar\n${endColour}"
	echo -e "\t\t${purpleColour}HTB${endColour}${yellowColour}:\t\t Template de HackTheBox${endColour}"
	echo -e "\t\t${purpleColour}THM${endColour}${yellowColour}:\t\t Template de TryHackMe${endColour}"
	echo -e "\n\n\t${grayColour}[-l]${endColour}${yellowColour} Lista los Latex creados de cierto tipo \n${endColour}"
	echo -e "\t\t${purpleColour}HTB${endColour}${yellowColour}:\t\t Lista Latex creados de tipo HTB${endColour}"
	echo -e "\t\t${purpleColour}THM${endColour}${yellowColour}:\t\t Lista latex creados de tipo THM${endColour}"
	echo -e "\t\t${purpleColour}ALL${endColour}${yellowColour}:\t\t Lista latex creados de cualquier tipo${endColour}"
	echo -e "\n\t${grayColour}[-n]${endColour}${yellowColour} Nombre del latex que se desea crear${endColour}${blueColour} (Ejemplo: -n Skynet)${endColour}"
	echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"

	tput cnorm; exit 1
}

# Variables globales


function createFile(){

  type_file=$1
  name_file=$2

  cp ~/.LaTexScript/${type_file}/template.tex . && mv template.tex ${name_file}.tex 
  sed -i "s|Nombre de la Maquina|$name_file|g" "$name_file.tex"
  sed -i "s|___NOMBRE___|___${name_file}___|g" "$name_file.tex"
  sed -i "s|___TIPO___|___${type_file}___|g" "$name_file.tex"

  tput cnorm; exit 0

}

function listTemplateFiles(){

  type_file=$1


  if [ "$(cat ~/.LaTexScript/lista_archivos | wc -l)" == "1" ];then
	  echo -e "\n${redColour}[!] Primero has un latexScript.sh -s ...\n${endColour}"
    return 1
  fi
 
  if [ "$type_file" = "ALL" ]; then
    lista_archivos=$(cat ~/.LaTexScript/lista_archivos)
  else
    lista_archivos=$(cat ~/.LaTexScript/lista_archivos | grep "$type_file")
  fi
 

  echo 'Nombre$Tipo$direccion' > tmp.aux

  for val in $lista_archivos; do
    echo $val >> tmp.aux
  done
  
  if [ "$type_file" = "THM" ]; then
    echo -ne "${redColour}"
  elif [ "$type_file" = "HTB" ]; then
    echo -ne "${greenColour}"
  elif [ "$type_file" = "ALL" ]; then
    echo -ne "${blueColour}"
  fi
  printTable '$' "$(cat tmp.aux)"
  echo -ne "${endColour}"


  rm tmp.aux

  tput cnorm; exit 0

}


function scanFiles(){
 
  echo '' > ~/.LaTexScript/lista_archivos

  temporal=$(find /home -type f -name "*.tex" 2>/dev/null)
  
  for val in $temporal; do
    buscar=$(grep "TIPO" $val)
    #echo $buscar
    if [ "$buscar" ]; then
      f_type=$(echo $buscar | tr -d "%_*" | awk '{print $2}')
      f_name=$(echo $val | tr "/" " " | awk '{print $NF}')
      if [ "$f_type" != "TIPO" ]; then
        echo "${f_name}\$${f_type}\$${val}" >> ~/.LaTexScript/lista_archivos
      fi
    fi
  done
  
  tput cnorm; exit 0
}


parameter_counter=0
while getopts "t:l:n:sh" arg; do
	case $arg in
		t) type_file=$OPTARG; let parameter_counter+=1;;
		l) list_type=$OPTARG; let parameter_counter+=1;;
		n) name_file=$OPTARG; let parameter_counter+=1;;
    s) scanFiles;;
    h) helpPanel;;
	esac
done

tput civis

if [ $parameter_counter -eq 0 ]; then
	helpPanel
else
  if [ "$(echo $type_file)" == "HTB" ] || [ "$(echo $type_file)" == "THM" ]; then
    if [ !"$name_file" ]; then
      createFile $type_file $name_file
		fi
  elif [ "$(echo $list_type)" == "HTB" ] || [ "$(echo $list_type)" == "THM" ] || [ "$(echo $list_type)" == "ALL" ];then
    listTemplateFiles $list_type
	fi
fi

tput cnorm; exit 1



