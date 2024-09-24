#!bin/bash

# Script para comparar tiempos de ejecución del mismo programa (simple2.c) con diferentes opciones de compilación (O0, O1, O2, O3 con y sin vectorización)

# Inicializo variables
repetitions=2
fDat=rendimiento.dat
exe=ejecutable
dat=datos

mkdir -p $exe
mkdir -p $dat

# Borro el fichero de datos si ya existe
rm -f $dat/$fDat

# Creo el fichero de datos
touch $dat/$fDat

# Compilación con O0 y sin vectorización
gcc -O0 -fno-tree-vectorize simple2.c -o $exe/simple2_O0_no_vector

# Compilación con O0 y con vectorización
gcc -O0 -ftree-vectorize simple2.c -o $exe/simple2_O0_vector

# Compilación con O1 y sin vectorización
gcc -O1 -fno-tree-vectorize simple2.c -o $exe/simple2_O1_no_vector

# Compilación con O1 y con vectorización
gcc -O1 -ftree-vectorize simple2.c -o $exe/simple2_O1_vector

# Compilación con O2 y sin vectorización
gcc -O2 -fno-tree-vectorize simple2.c -o $exe/simple2_O2_no_vector

# Compilación con O2 y con vectorización
gcc -O2 -ftree-vectorize simple2.c -o $exe/simple2_O2_vector

# Compilación con O3 y sin vectorización
gcc -O3 -fno-tree-vectorize simple2.c -o $exe/simple2_O3_no_vector

# Compilación con O3 y con vectorización
gcc -O3 -ftree-vectorize simple2.c -o $exe/simple2_O3_vector

# Ejecución de los programas compilados
for ((i=0; i < $repetitions; i++)); do
    O0_noVector=$(./$exe/simple2_O0_no_vector | grep 'Tiempo' | awk '{print $2}')

    O0_vector=$(./$exe/simple2_O0_vector | grep 'Tiempo' | awk '{print $2}')

    O1_noVector=$(./$exe/simple2_O1_no_vector | grep 'Tiempo' | awk '{print $2}')

    O1_vector=$(./$exe/simple2_O1_vector | grep 'Tiempo' | awk '{print $2}')

    O2_noVector=$(./$exe/simple2_O2_no_vector | grep 'Tiempo' | awk '{print $2}')

    O2_vector=$(./$exe/simple2_O2_vector | grep 'Tiempo' | awk '{print $2}')

    O3_noVector=$(./$exe/simple2_O3_no_vector | grep 'Tiempo' | awk '{print $2}')

    O3_vector=$(./$exe/simple2_O3_vector | grep 'Tiempo' | awk '{print $2}')

    echo "$O0_noVector $O0_vector $O1_noVector $O1_vector $O2_noVector $O2_vector $O3_noVector $O3_vector" >> $dat/$fDat

    done


# Calculo de la media de los tiempos de ejecución obteniendo los valores linea a linea del fichero de datos, sumandolos y dividiendo por el número de repeticiones

for ((i=0; i < $repetitions; i++)); do

    #Obtengo la linea i del fichero de datos
    linea=$(sed -n "$((i+1))p" $dat/$fDat)
    echo $linea

    #TODO: Arreglar esta parte del script para que calcule la media de los tiempos de ejecución
    #Obtengo los valores de la linea
    O0_noVector=$(echo $linea | awk '{print $1}')
    O0_vector=$(echo $linea | awk '{print $2}')
    O1_noVector=$(echo $linea | awk '{print $3}')
    O1_vector=$(echo $linea | awk '{print $4}')
    O2_noVector=$(echo $linea | awk '{print $5}')
    O2_vector=$(echo $linea | awk '{print $6}')
    O3_noVector=$(echo $linea | awk '{print $7}')
    O3_vector=$(echo $linea | awk '{print $8}')

done

# Eliminación de los programas compilados
rm $exe/simple2_O0_no_vector $exe/simple2_O0_vector $exe/simple2_O1_no_vector $exe/simple2_O1_vector $exe/simple2_O2_no_vector $exe/simple2_O2_vector $exe/simple2_O3_no_vector $exe/simple2_O3_vector
rmdir $exe

echo "Datos guardados en $dat/$fDat"