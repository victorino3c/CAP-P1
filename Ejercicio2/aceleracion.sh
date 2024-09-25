#!bin/bash

# Script para calcular la aceleracion (time1/time2) de dos programas (simple2 y simple2_intrinsics) en funcion del numero de trials
# Estos datos se encuentran en la 2da y 3ra columna del fichero de datos rendimiento.dat

# Variables
fDat=rendimiento.dat
fAceleracion=aceleracion.dat
dat=datos

# Verifica si el fichero de datos existe
if [ ! -f "$dat/$fDat" ]; then
  echo "El fichero de datos $dat/$fDat no existe."
  exit 1
fi

# Creo los ficheros de datos
rm -f $dat/$fAceleracion

touch $dat/$fAceleracion

# Bucle para calcular la aceleracion
while read trials time1 time2
do
    aceleracion=$(echo "scale=6; $time1/$time2" | bc)
    echo $trials $aceleracion >> $dat/$fAceleracion
done < $dat/$fDat

echo "Fichero de aceleracion generado en $dat/$fAceleracion"

bash grafica_aceleracion.sh

exit 0