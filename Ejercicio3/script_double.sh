tam=100000
echo "iteracion tamaño res_naive time_naive res_simd time_simd speedup" > dotproductdataO0.txt
echo "iteracion tamaño res_naive time_naive res_simd time_simd speedup" > dotproductdataO1.txt
echo "iteracion tamaño res_naive time_naive res_simd time_simd speedup" > dotproductdataO2.txt
echo "iteracion tamaño res_naive time_naive res_simd time_simd speedup" > dotproductdataO3.txt
for i in 8191 8192 16383 16384 32765 32768 131070 131072 262141 262144 512212 512215
do
    gcc dot_product.c -g -fopt-info -DREPS=10 -DARRAYSIZE=$i -lm -march=native -fwhole-program -Wall -D_GNU_SOURCE -o dot_producto
    gcc dot_product.c -O1 -g -fopt-info -DREPS=10 -DARRAYSIZE=$i -lm -march=native -fwhole-program -Wall -D_GNU_SOURCE -o dot_productoO1
    gcc dot_product.c -O2 -g -fopt-info -DREPS=10 -DARRAYSIZE=$i -lm -march=native -fwhole-program -Wall -D_GNU_SOURCE -o dot_productoO2
    gcc dot_product.c -O3 -g -fopt-info -DREPS=10 -DARRAYSIZE=$i -lm -march=native -fwhole-program -Wall -D_GNU_SOURCE -o dot_productoO3
    ./dot_producto dotproductdataO0.txt
    ./dot_productoO1 dotproductdataO1.txt
    ./dot_productoO2 dotproductdataO2.txt
    ./dot_productoO3 dotproductdataO3.txt
done