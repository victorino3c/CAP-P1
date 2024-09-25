#!bin/bash

# Script para generar una gráfica con la aceleración de dos programas (simple2 y simple2_intrinsics) en función del número de trials
# Estos datos se encuentran en el fichero de datos aceleracion.dat

# Variables
fAceleracion=aceleracion.dat
fGraf=grafica_aceleracion.png
dat=datos

# Verifica si el fichero de datos existe
if [ ! -f "$dat/$fAceleracion" ]; then
  echo "El fichero de datos $dat/$fAceleracion no existe."
  exit 1
fi

# Creo la gráfica
gnuplot << END_GNUPLOT
set title "Aceleración de los programas simple2 y simple2intrinsics"
set ylabel "Aceleración"
set xlabel "Número de trials (cientos de miles)"
set terminal png
set output "$dat/$fGraf"

# Obtengo el rango de la primera columna del fichero de datos
stats "$dat/$fAceleracion" using 1 nooutput
set xrange [STATS_min:STATS_max]

set yrange [1:3]

plot "$dat/$fAceleracion" using 1:2 with lines title "Aceleración"
replot
quit
END_GNUPLOT