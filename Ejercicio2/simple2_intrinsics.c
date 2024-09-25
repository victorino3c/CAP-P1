#include <stdlib.h> 
#include <stdio.h> 
#include <immintrin.h>
#include <time.h>
 
#define ARRAY_SIZE 2048 
#define NUMBER_OF_TRIALS 1//1000000 
 
/* 
 * Statically allocate our arrays.  Compilers can 
 * align them correctly. 
 */ 
static double a[ARRAY_SIZE], b[ARRAY_SIZE], c; 
 
long get_time_in_nanoseconds() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000000000L + ts.tv_nsec;
}

int main(int argc, char *argv[]) { 
    int i,t; 
 
    double m = 1.0001;
    long trials;

    if (argc > 1) {
        trials = atol(argv[1]);
    } else {
        trials = NUMBER_OF_TRIALS;
    }
 
    /* loop1: Populate A and B arrays */ 
    for (i=0; i < ARRAY_SIZE; i+= 4) { 
        __m256d va = {i+4, i+3, i+2, i+1};
        _mm256_store_pd(&a[i], va);

        __m256d vb = {i+3, i+2, i+1, i};
        _mm256_store_pd(&b[i], vb);
        // b[i] = i; 
        // a[i] = i+1; 
    } 

    long start_time = get_time_in_nanoseconds();

    /* loop2 y loop3(inner) Perform an operation a number of times */ 
    for (t=0; t < trials; t++) { 
        __m256d mm = {1.0001, 1.0001, 1.0001, 1.0001}; 
        __m256d sum = {0.0, 0.0, 0.0, 0.0}; // to hold partial sums 

        for (i=0; i < ARRAY_SIZE; i+=4) { 
            //c += m*a[i] + b[i];

            // Load arrays 
            __m256d va = _mm256_load_pd(&a[i]); 
            __m256d vb = _mm256_load_pd(&b[i]); 

            // Compute m*a+b 
            __m256d tmp = _mm256_fmadd_pd (mm, va, vb); 
            // Accumulate results 
            sum = _mm256_add_pd (tmp, sum); 
        } 

        // Sum the partial values of the sum vector, to get the final result
        for (i = 0; i < 4; i++) { 
            c += sum[i]; 
        }

        //printf("c = %lf\n", c);
    } 

    long end_time = get_time_in_nanoseconds();

    printf("Tiempo %ld \n", /*(double)*/(end_time - start_time)/*/ 1000000000L*/);
 
    return 0; 
} 