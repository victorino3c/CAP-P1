#!bin/bash

# Script para comparar el rendimiento de dos programas (simple2 y simple2_instrinsics) en funcion del numero de trials

# Variables
p1="simple2"
p2="simple2_intrinsics"
min=100000
max=1000000
step=100000
dat=datos
datos=rendimiento.dat

mkdir -p $dat

# Borro los ficheros de datos si ya existen
rm -f $dat/$datos

# Creo los ficheros de datos
touch $dat/$datos

# Bucle para ejecutar los programas
for ((i=$min; i<=$max; i+=$step))
do
    # echo "Ejecutando $p1 con $i trials"
    time1=$(./$p1 $i | grep 'Tiempo' | awk '{print $2}')

    # echo "Ejecutando $p2 con $i trials"
    time2=$(./$p2 $i | grep 'Tiempo' | awk '{print $2}')

    #Divido los tiempos entre 1000000000 para obtener el tiempo en segundos
    time1=$(echo "scale=6; $time1/1000000000" | bc)
    time2=$(echo "scale=6; $time2/1000000000" | bc)

    echo $i $time1 $time2 >> $dat/$datos

done

echo "Datos guardados en $dat/$datos"

bash grafica_rendimiento.sh

bash aceleracion.sh

exit 0