#!/bin/bash

# Script para comparar el rendimiento del algoritmo para convertir en gris una imagen original (greyScale) y vectorizado (GreyScaleVectorized)
# Para ello vamos a recomplilar los tiempos de cada uno para distintas calidades de imagen y luego compararlos

# Parametros:
fDat="datos.dat"
fMed="medias.dat"
repetitions=10

# Borramos el archivo de datos si existe
if [ -f $fDat ]; then
    rm $fDat
fi

# Borramos el archivo de medias si existe
if [ -f $fMed ]; then
    rm $fMed
fi

for ((i=1; i<=$repetitions; i+=1)); do
    
    SD=$(./greyScale SD.jpg | grep 'Tiempo:' | awk '{print $2}')
    HD=$(./greyScale HD.jpg | grep 'Tiempo:' | awk '{print $2}')
    FHD=$(./greyScale FHD.jpg | grep 'Tiempo:' | awk '{print $2}')
    ck=$(./greyScale 4k.jpg | grep 'Tiempo:' | awk '{print $2}')
    ok=$(./greyScale 8k.jpg | grep 'Tiempo:' | awk '{print $2}')

    SDV=$(./greyScaleVectorized SD.jpg | grep 'Tiempo:' | awk '{print $2}')
    HDV=$(./greyScaleVectorized HD.jpg | grep 'Tiempo:' | awk '{print $2}')
    FHDV=$(./greyScaleVectorized FHD.jpg | grep 'Tiempo:' | awk '{print $2}')
    ckV=$(./greyScaleVectorized 4k.jpg | grep 'Tiempo:' | awk '{print $2}')
    okV=$(./greyScaleVectorized 8k.jpg | grep 'Tiempo:' | awk '{print $2}')

    echo "$SD $HD $FHD $ck $ok $SDV $HDV $FHDV $ckV $okV" >> $fDat

done

# Inicializamos las variables de suma
sum_SD=0
sum_HD=0
sum_FHD=0
sum_ck=0
sum_ok=0
sum_SDV=0
sum_HDV=0
sum_FHDV=0
sum_ckV=0
sum_okV=0

for ((i=0; i < $repetitions; i++)); do

    # Obtengo la linea i del fichero de datos
    linea=$(sed -n "$((i+1))p" $fDat)

    # Obtengo los valores de la linea y sumo usando bc
    sum_SD=$(echo "$sum_SD + $(echo $linea | awk '{print $1}')" | bc -l)
    sum_HD=$(echo "$sum_HD + $(echo $linea | awk '{print $2}')" | bc -l)
    sum_FHD=$(echo "$sum_FHD + $(echo $linea | awk '{print $3}')" | bc -l)
    sum_ck=$(echo "$sum_ck + $(echo $linea | awk '{print $4}')" | bc -l)
    sum_ok=$(echo "$sum_ok + $(echo $linea | awk '{print $5}')" | bc -l)
    sum_SDV=$(echo "$sum_SDV + $(echo $linea | awk '{print $6}')" | bc -l)
    sum_HDV=$(echo "$sum_HDV + $(echo $linea | awk '{print $7}')" | bc -l)
    sum_FHDV=$(echo "$sum_FHDV + $(echo $linea | awk '{print $8}')" | bc -l)
    sum_ckV=$(echo "$sum_ckV + $(echo $linea | awk '{print $9}')" | bc -l)
    sum_okV=$(echo "$sum_okV + $(echo $linea | awk '{print $10}')" | bc -l)

done

# Calculo la media de los tiempos usando bc
SD=$(echo "scale=6; $sum_SD / $repetitions" | bc -l)
HD=$(echo "scale=6; $sum_HD / $repetitions" | bc -l)
FHD=$(echo "scale=6; $sum_FHD / $repetitions" | bc -l)
ck=$(echo "scale=6; $sum_ck / $repetitions" | bc -l)
ok=$(echo "scale=6; $sum_ok / $repetitions" | bc -l)
SDV=$(echo "scale=6; $sum_SDV / $repetitions" | bc -l)
HDV=$(echo "scale=6; $sum_HDV / $repetitions" | bc -l)
FHDV=$(echo "scale=6; $sum_FHDV / $repetitions" | bc -l)
ckV=$(echo "scale=6; $sum_ckV / $repetitions" | bc -l)
okV=$(echo "scale=6; $sum_okV / $repetitions" | bc -l)

# Guardamos las medias en un archivo
echo "SD HD FHD 4k 8k SDV HDV FHDV 4kV 8kV" >> $fMed
echo "$SD $HD $FHD $ck $ok $SDV $HDV $FHDV $ckV $okV" >> $fMed

# Borramos las imagenes generadas
rm -f SD_grey.jpg HD_grey.jpg FHD_grey.jpg 4k_grey.jpg 8k_grey.jpg

echo "Datos guardados en $fDat"
echo "Medias guardadas en $fMed"
