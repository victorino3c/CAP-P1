#ifndef ITER
#define ITER 25
#endif

#ifndef ARRAYSIZE
#pragma message("ARRAYSIZE not defined. Check compile command")
#define ARRAYSIZE 1000000
#endif

#ifndef REPS
#define REPS 1
#endif

// #define STATIC_MEM

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>
#include <immintrin.h>

typedef unsigned long long ull;

void initarray(double *a, ssize_t n)
{
    for (ssize_t i = 0; i < n; i++)
    {
        a[i] = rand() / (rand() + 1);
    }
}

static inline double naive_dot_product(double *a, double *b, ssize_t n)
{
    double res = 0.0;
    ssize_t i = 0;
    for (i = 0; i < n; i++)
    {
        res += a[i] * b[i];
    }
    return res;
}

static inline double reversed_dot_product(double *a, double *b, ssize_t n)
{
    double res = 0.0;
    ssize_t i = 0;
    for (i = n - 1; i >= 0; i--)
    {
        res += a[i] * b[i];
    }
    return res;
}

/* Horizontal add works within 128-bit lanes. Use scalar ops to add
 * across the boundary. */
static inline double reduce_vector1(__m256d input)
{
    __m256d temp = (__m256d)_mm256_hadd_pd(input, input);
    return ((double *)&temp)[0] + ((double *)&temp)[2];
}

/* Another way to get around the 128-bit boundary: grab the first 128
 * bits, grab the lower 128 bits and then add them together with a 128
 * bit add instruction. */
static inline double reduce_vector2(__m256d input)
{
    __m256d temp = _mm256_hadd_pd(input, input);
    __m128d sum_high = _mm256_extractf128_pd(temp, 1);
    __m128d result = _mm_add_pd(sum_high, _mm256_castpd256_pd128(temp));
    return ((double *)&result)[0];
}

static inline double avx_dot_product(const double *a, const double *b, ssize_t n)
{
    __m256d sum_vec = _mm256_set_pd(0.0, 0.0, 0.0, 0.0);

    /* Add up partial dot-products in blocks of 256 bits */
    for (ssize_t ii = 0; ii < n; ii += 4)
    {
        __m256d x = _mm256_load_pd(a + ii);
        __m256d y = _mm256_load_pd(b + ii);
        __m256d z = _mm256_mul_pd(x, y);
        sum_vec = _mm256_add_pd(sum_vec, z);
    }

    /* Find the partial dot-product for the remaining elements after
     * dealing with all 256-bit blocks. */
    double final = 0.0;
    for (ssize_t ii = n - (n % 4); ii < n; ++ii)
        final += a[ii] * b[ii];

    return reduce_vector2(sum_vec) + final;
}

int main(int argc, char **argv)
{

    if (argc < 2 || argc > 2)
    {
        printf(" uso: dot_product dotproductdata.txt \n");
        return 0;
    }
    const char *filename = argv[1];
    FILE *fp = fopen(filename, "a");
    if (fp == NULL)
    {
        perror(filename);
        return -1;
    }

#ifdef STATIC_MEM
    __attribute__((aligned(32))) double a[ARRAYSIZE], b[ARRAYSIZE];
#else
    double *a, *b;
    a = aligned_alloc(256, ARRAYSIZE * sizeof(double));
    b = aligned_alloc(256, ARRAYSIZE * sizeof(double));
#endif

    struct timespec ini, fin;
    ull time_naive = 0, time_avx = 0;
    initarray(a, ARRAYSIZE);
    initarray(b, ARRAYSIZE);
    double answers_naive[REPS] = {0}, answers_avx[REPS] = {0};
    double answer_naive = 0, answer_avx = 0;
    double speedup = 0;
    for (ull iter = 0; iter < ITER; iter++)
    {

#define CLOCK_METHOD CLOCK_PROCESS_CPUTIME_ID

        clock_gettime(CLOCK_METHOD, &ini); // gettimeofday(&ini,NULL);
        for (ull r = 0; r < REPS; r++)
            answers_naive[r] = naive_dot_product(a, b, ARRAYSIZE);
        clock_gettime(CLOCK_METHOD, &fin); // gettimeofday(&fin,NULL);
        for (ull r = 0; r < REPS; r++)
            answer_naive += answers_naive[r];
        answer_naive = answer_naive / REPS;
        time_naive = (fin.tv_sec * 1000000000 + fin.tv_nsec) - (ini.tv_sec * 1000000000 + ini.tv_nsec);

        clock_gettime(CLOCK_METHOD, &ini); // gettimeofday(&ini,NULL);
        for (ull r = 0; r < REPS; r++)
            answers_avx[r] = avx_dot_product(a, b, ARRAYSIZE);
        clock_gettime(CLOCK_METHOD, &fin); // gettimeofday(&fin,NULL);
        for (ull r = 0; r < REPS; r++)
            answer_avx += answers_avx[r];
        answer_avx = answer_avx / REPS;
        time_avx = (fin.tv_sec * 1000000000 + fin.tv_nsec) - (ini.tv_sec * 1000000000 + ini.tv_nsec);

        speedup = ((double)time_naive) / ((double)time_avx);
        fprintf(fp, "%llu %u %lf %llu %lf %llu %lf\n", iter, ARRAYSIZE, answer_naive, time_naive, answer_avx, time_avx, speedup);
    }

#ifndef STATIC_MEM
    free(a);
    free(b);
#endif
    fclose(fp);
}