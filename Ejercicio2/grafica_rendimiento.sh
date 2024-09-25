#!/bin/bash

# Script para comparar el rendimiento de dos programas (simple2 y simple2_intrinsics) en función del número de trials en una gráfica

# Variables
fDat=rendimiento.dat
fGraf=grafica_rendimiento.png
dat=datos

# Verifica si el fichero de datos existe
if [ ! -f "$dat/$fDat" ]; then
  echo "El fichero de datos $dat/$fDat no existe."
  exit 1
fi

# Creo la gráfica
gnuplot << END_GNUPLOT
set title "Rendimiento de los programas simple2 y simple2intrinsics"
set ylabel "Tiempo (s)"
set xlabel "Número de trials (cientos de miles)"
set terminal png
set output "$dat/$fGraf"

# Obtengo el rango de la primera columna del fichero de datos
stats "$dat/$fDat" using 1 nooutput
set xrange [STATS_min:STATS_max]

plot "$dat/$fDat" using 1:2 with lines title "simple2", "$dat/$fDat" using 1:3 with lines title "simple2intrinsics"
replot
quit
END_GNUPLOT

echo "Gráfica generada en $dat/$fGraf"