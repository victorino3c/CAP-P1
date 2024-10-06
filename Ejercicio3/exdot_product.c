/* Compute the dot product of two (properly aligned) vectors. */
/* Limitado a tamaños reserva mem de 512215x8xbytesx2 (aprox 8 MBytes) */

#define MAX_ITER 5
#define MAX_N 512215
#define NUM_TAM 12

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <immintrin.h>

double slow_dot_product(const double *a, const double *b, int num_elem) {
  double answer = 0.0;
  for(int ii = 0; ii < num_elem; ++ii)
    answer += a[ii]*b[ii];
  return answer;
}

double reverse_slow_dot_product(const double *a, const double *b, int num_elem) {
  double rev_answer = 0.0;
  for(int ii = 0; ii < num_elem; ++ii)
    rev_answer += a[num_elem-ii-1]*b[num_elem-ii-1];
  return rev_answer;
}

/* Horizontal add works within 128-bit lanes. Use scalar ops to add
 * across the boundary. */
double reduce_vector1(__m256d input) {
  __m256d temp = (__m256d) _mm256_hadd_pd(input, input);
  return ((double*)&temp)[0] + ((double*)&temp)[2];
}

/* Another way to get around the 128-bit boundary: grab the first 128
 * bits, grab the lower 128 bits and then add them together with a 128
 * bit add instruction. */
double reduce_vector2(__m256d input) {
  __m256d temp = _mm256_hadd_pd(input, input);
  __m128d sum_high = _mm256_extractf128_pd(temp, 1);
  __m128d result = _mm_add_pd(sum_high, _mm256_castpd256_pd128(temp));
  return ((double*)&result)[0];
}

double dot_product(const double *a, const double *b, int num_elem) {
  __m256d sum_vec = _mm256_set_pd(0.0, 0.0, 0.0, 0.0);

  /* Add up partial dot-products in blocks of 256 bits */
  for(int ii = 0; ii < num_elem/4; ++ii) {
    __m256d x = _mm256_load_pd(a+4*ii);
    __m256d y = _mm256_load_pd(b+4*ii);
    __m256d z = _mm256_mul_pd(x,y);
    sum_vec = _mm256_add_pd(sum_vec, z);
  }

  /* Find the partial dot-product for the remaining elements after
   * dealing with all 256-bit blocks. */
  double final = 0.0;
  for(int ii = num_elem-num_elem%4; ii < num_elem; ++ii)
    final += a[ii] * b[ii];

  return reduce_vector2(sum_vec) + final;
}


int main(int argc, char **argv) {

  __attribute__ ((aligned (32))) double a[MAX_N], b[MAX_N];
    struct timeval fin,ini;
  long int tiempo[MAX_ITER],tiempodot[MAX_ITER];
  double answer[MAX_ITER], answerdot[MAX_ITER], rev_answerdot[MAX_ITER];;
  float acel;

  int tam[NUM_TAM];

  int tam0 = 8191; tam[0]=tam0;
  int tam1 = 8192; tam[1]=tam1;
  int tam2 = 16383; tam[2]=tam2;
  int tam3 = 16384; tam[3]=tam3;
  int tam_L1d = 32768; tam[4]=tam_L1d;
  int tam_L1di = 32765; tam[5]=tam_L1di;
  int tam6= 131072; tam[6]=tam6;
  int tam7= 131070; tam[7]=tam7;
  int tam_L2 = 262144; tam[8]=tam_L2;
  int tam_L2i = 262141; tam[9]=tam_L2i;
  int tam10 = 512215; tam[10]=tam10;
  int tam11 = 512212; tam[11]=tam11;


   int N = MAX_N;
  // asignación de valores
  for(int ii = 0; ii < N; ++ii){
    a[ii] = b[ii] = ii/sqrt(N);
    }
  // tamaños de vector
  for( int k=0 ; k<NUM_TAM; k++) {                  // VECTORES DE DISTINTOS TAMAÑOS
    N=tam[k];
    printf(" tamaño de vector N = %d \n", N);
    for (int iter=0; iter< MAX_ITER; iter++){   //ITERACIONES
      //producto SIMD
      gettimeofday(&ini,NULL);
      answer[iter] = dot_product(a, b, N);
      gettimeofday(&fin,NULL);
      tiempo[iter]=(fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec);
      printf("iter = %d ,resultado SIMD =%f y tiempo SIMD: %ld us. \n", iter, answer[iter], tiempo[iter]);

      // producto secuencial escalar
      gettimeofday(&ini,NULL);
      answerdot[iter] = slow_dot_product(a, b, N);
      gettimeofday(&fin,NULL);
      tiempodot[iter]=(fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec);
      rev_answerdot[iter] = reverse_slow_dot_product(a, b, N);
      acel=(float)tiempodot[iter]/(float)tiempo[iter];
      printf("iter = %d ,result sec1 =%f, result sec2 =%f y tiempo sec: %ld us. aceleración %f\n", iter, answerdot[iter], rev_answerdot[iter], tiempodot[iter], acel);
      }
    }
}