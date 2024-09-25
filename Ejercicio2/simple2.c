#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define ARRAY_SIZE 2048
#define NUMBER_OF_TRIALS 1000000

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

    /* Populate A and B arrays */
    for (i=0; i < ARRAY_SIZE; i++) {
        b[i] = i;
        a[i] = i+1;
    }

    long start_time = get_time_in_nanoseconds();

    /* Perform an operation a number of times */
    for (t=0; t < trials; t++) {
        for (i=0; i < ARRAY_SIZE; i++) {
            c += m*a[i] + b[i];
        }

        //printf("c = %lf\n", c);
    }

    long end_time = get_time_in_nanoseconds();

    printf("Tiempo %ld \n", /*(double)*/(end_time - start_time)/*/ 1000000000L*/);

    return 0;
}