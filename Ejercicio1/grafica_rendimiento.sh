#!/bin/bash

# Script para generar gráfica de rendimiento de los programas compilados con diferentes opciones de compilación
# Datos se encuentran en /datos/medias.dat

# Inicializo variables
fMed=medias.dat
fGraf=grafica_rendimiento.png
dat=datos

# Verifica que el archivo de datos no esté vacío
if [ ! -s "$dat/$fMed" ]; then
  echo "Error: El archivo de datos $dat/$fMed está vacío o no existe."
  exit 1
fi

# Creo la gráfica
gnuplot << END_GNUPLOT
set title "Rendimiento de los programas compilados con diferentes opciones de compilación"

set ylabel "Tiempo (s)"
set xlabel "Opciones de compilación"

set style data histograms
set style fill solid 1.00 border -1
set boxwidth 0.5

set xtics ("O0_sin" 1, "O0_con" 2, "O1_sin" 3, "O1_con" 4, "O2_sin" 5, "O2_con" 6, "O3_sin" 7, "O3_con" 8)

set terminal png
set output "$dat/$fGraf"

plot "$dat/$fMed" using 2:xtic(1) with boxes title "Tiempo de ejecución"

replot
quit
END_GNUPLOT

echo "Gráfica generada en $dat/$fGraf"