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
    echo "No hay archivos."     
    return 1
  fi
 
  if [ "$type_file" = "ALL" ]; then
    lista_archivos=$(cat ~/.LaTexScript/lista_archivos)
  else
    lista_archivos=$(cat ~/.LaTexScript/lista_archivos | grep "$type_file")
  fi
  
  echo '' > tmp.aux

  for val in $lista_archivos; do
    echo $val >> tmp.aux
  done

  



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



