#!/bin/bash

# Script para generar gráfica de rendimiento O2 con y sin vectorización
# Datos se encuentran en /datos/medias.dat

# Inicializo variables
fMed=medias.dat
fGraf=grafica_O2.png
dat=datos

# Verifica que el archivo de datos no esté vacío
if [ ! -s "$dat/$fMed" ]; then
  echo "Error: El archivo de datos $dat/$fMed está vacío o no existe."
  exit 1
fi

# Creo la gráfica
gnuplot << END_GNUPLOT
set title "Rendimiento O2 con y sin vectorización"

set ylabel "Tiempo (s)"
set xlabel "Opciones de compilación"

set style data histograms
set style fill solid 1.00 border -1
set boxwidth 0.5

set xtics ("O2_sin" 1, "O2_con" 2)

set terminal png
set output "$dat/$fGraf"

plot "$dat/$fMed" every ::4::5 using 2:xtic(1) with boxes title "Tiempo de ejecución"

replot
quit
END_GNUPLOT

echo "Gráfica O2 generada en $dat/$fGraf"