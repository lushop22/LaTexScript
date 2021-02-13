#/bin/bash

variableHTB="$(pwd)/HTB"
variableTHM="$(pwd)/THM"

sed -i "s|DIRECCION_ACTUAL|$variableHTB|g" "$variableHTB/template.tex"
sed -i "s|DIRECCION_ACTUAL|$variableTHM|g" "$variableTHM/template.tex"


