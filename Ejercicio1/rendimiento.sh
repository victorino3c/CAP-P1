#!bin/bash

# Script para comparar tiempos de ejecución del mismo programa (simple2.c) con diferentes opciones de compilación (O0, O1, O2, O3 con y sin vectorización)

# Inicializo variables
repetitions=2
fDat=rendimiento.dat
fMed=medias.dat
exe=ejecutable
dat=datos

mkdir -p $exe
mkdir -p $dat

# Borro los ficheros de datos si ya existen
rm -f $dat/$fDat
rm -f $dat/$fMed

# Creo los ficheros de datos
touch $dat/$fDat
touch $dat/$fMed

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
# El bucle empieza en 0 y termina en $repetitions - 1 ya que las variables ya guardan de base el valor de la ultima ejecución
for ((i=0; i < $repetitions - 1; i++)); do

    #Obtengo la linea i del fichero de datos
    linea=$(sed -n "$((i+1))p" $dat/$fDat)

    #TODO: Arreglar esta parte del script para que calcule la media de los tiempos de ejecución
    #Obtengo los valores de la linea
    O0_noVector=$((O0_noVector + $(echo $linea | awk '{print $1}')))
    O0_vector=$((O0_vector + $(echo $linea | awk '{print $2}')))
    O1_noVector=$((O1_noVector + $(echo $linea | awk '{print $3}')))
    O1_vector=$((O1_vector + $(echo $linea | awk '{print $4}')))
    O2_noVector=$((O2_noVector + $(echo $linea | awk '{print $5}')))
    O2_vector=$((O2_vector + $(echo $linea | awk '{print $6}')))
    O3_noVector=$((O3_noVector + $(echo $linea | awk '{print $7}')))
    O3_vector=$((O3_vector + $(echo $linea | awk '{print $8}')))

done

#Calculo de la media, ademñas de pasar los nanosegundos a segundos
O0_noVector=$(echo "scale=6; $O0_noVector / (1000000000 * $repetitions)" | bc)
O0_vector=$(echo "scale=6; $O0_vector / (1000000000 * $repetitions)" | bc)
O1_noVector=$(echo "scale=6; $O1_noVector / (1000000000 * $repetitions)" | bc)
O1_vector=$(echo "scale=6; $O1_vector / (1000000000 * $repetitions)" | bc)
O2_noVector=$(echo "scale=6; $O2_noVector / (1000000000 * $repetitions)" | bc)
O2_vector=$(echo "scale=6; $O2_vector / (1000000000 * $repetitions)" | bc)
O3_noVector=$(echo "scale=6; $O3_noVector / (1000000000 * $repetitions)" | bc)
O3_vector=$(echo "scale=6; $O3_vector / (1000000000 * $repetitions)" | bc)

#echo $O0_noVector $O0_vector $O1_noVector $O1_vector $O2_noVector $O2_vector $O3_noVector $O3_vector >> $dat/$fMed
echo "O0sin $O0_noVector" >> $dat/$fMed
echo "O0con $O0_vector" >> $dat/$fMed
echo "O1sin $O1_noVector" >> $dat/$fMed
echo "O1con $O1_vector" >> $dat/$fMed
echo "O2sin $O2_noVector" >> $dat/$fMed
echo "O2con $O2_vector" >> $dat/$fMed
echo "O3sin $O3_noVector" >> $dat/$fMed
echo "O3con $O3_vector" >> $dat/$fMed

# LLamando a script para generar gráfica
bash grafica_rendimiento.sh
bash grafica_O0.sh
bash grafica_O1.sh
bash grafica_O2.sh
bash grafica_O3.sh

# Eliminación de los programas compilados
rm $exe/simple2_O0_no_vector $exe/simple2_O0_vector $exe/simple2_O1_no_vector $exe/simple2_O1_vector $exe/simple2_O2_no_vector $exe/simple2_O2_vector $exe/simple2_O3_no_vector $exe/simple2_O3_vector
rmdir $exe

echo "Datos guardados en $dat/$fDat"
echo "Medias guardadas en $dat/$fMed"