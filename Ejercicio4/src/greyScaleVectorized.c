#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <immintrin.h>

static inline void getRGB(uint8_t *im, int width, int height, int nchannels, int x, int y, __m256 *datal256ps, __m256 *datah256ps)
{
    __m128i datal128, datah128;
    __m256i datal256, datah256;

    unsigned char *offset = im + (x + width * y) * nchannels;
    // Cargar los primeros 8 bytes de la imagen en datal128
    datal128 = _mm_loadu_si128((__m128i *)offset);
    // Cargar los siguientes 8 bytes de la imagen en datah128
    datah128 = _mm_loadu_si128((__m128i *)(offset + 8));

    // Convertir a 32 bits enteros
    datal256 = _mm256_cvtepu8_epi32(datal128);
    datah256 = _mm256_cvtepu8_epi32(datah128);

    // Convertir a flotante (precisión simple)
    *datal256ps = _mm256_cvtepi32_ps(datal256);
    *datah256ps = _mm256_cvtepi32_ps(datah256);
}

int main(int nargs, char **argv)
{
    int width, height, nchannels;
    struct timeval fin, ini;

    __m256 coefficients = _mm256_set_ps(0.0, 0.1140, 0.5870, 0.2989, 0.0, 0.1140, 0.5870, 0.2989);
    __m256 datal256ps, datah256ps, result256;
    __m128i result128;

    if (nargs < 2)
    {
        printf("Usage: %s <image1> [<image2> ...]\n", argv[0]);
        return -1;
    }

    // Para cada imagen
    for (int file_i = 1; file_i < nargs; file_i++)
    {
        printf("[info] Processing %s\n", argv[file_i]);
        /****** Reading file ******/
        uint8_t *rgb_image = stbi_load(argv[file_i], &width, &height, &nchannels, 4);
        if (!rgb_image)
        {
            perror("Image could not be opened");
            return -1;
        }

        /****** Allocating memory ******/
        uint8_t *grey_image = malloc(width * height);
        if (!grey_image)
        {
            perror("Could not allocate memory");
            stbi_image_free(rgb_image);
            return -1;
        }

        for (int i = strlen(argv[file_i]) - 1; i >= 0; i--)
        {
            if (argv[file_i][i] == '.')
            {
                argv[file_i][i] = 0;
                break;
            }
        }

        char *grey_image_filename = 0;
        asprintf(&grey_image_filename, "%s_grey.jpg", argv[file_i]);
        if (!grey_image_filename)
        {
            perror("Could not allocate memory");
            free(grey_image);
            stbi_image_free(rgb_image);
            return -1;
        }

        /****** Computations ******/
        printf("[info] %s: width=%d, height=%d, nchannels=%d\n", argv[file_i], width, height, nchannels);

        if (nchannels != 3 && nchannels != 4)
        {
            printf("[error] Num of channels=%d not supported. Only three (RGB), four (RGBA) are supported.\n", nchannels);
            free(grey_image);
            stbi_image_free(rgb_image);
            continue;
        }

        gettimeofday(&ini, NULL);

        // RGB to grey scale
        for (int j = 0; j < height; j++)
        {
            for (int i = 0; i < width; i += 4)
            {
                getRGB(rgb_image, width, height, 4, i, j, &datal256ps, &datah256ps);

                datal256ps = _mm256_mul_ps(datal256ps, coefficients);
                datah256ps = _mm256_mul_ps(datah256ps, coefficients);

                result256 = _mm256_hadd_ps(datal256ps, datah256ps);
                result256 = _mm256_hadd_ps(result256, result256);

                // result256 = _mm256_permutevar8x32_ps(result256, _mm256_set_epi32(7, 1, 6, 0, 2, 3, 4, 5));

                // Convertir el resultado a enteros
                //result128 = _mm_cvtps_epi32(_mm256_extractf128_ps(result256, 0));
                result128 = _mm_cvtps_epi32(_mm256_castps256_ps128(result256));


                // Almacenar el resultado en la imagen de grises, teniendo en cuenta el little endian
                grey_image[j * width + i + 3] = _mm_extract_epi32(result128, 0);
                grey_image[j * width + i + 2] = _mm_extract_epi32(result128, 1);
                grey_image[j * width + i + 1] = _mm_extract_epi32(result128, 2);
                grey_image[j * width + i + 0] = _mm_extract_epi32(result128, 3);
            }
        }

        stbi_write_jpg(grey_image_filename, width, height, 1, grey_image, 100);
        free(rgb_image);

        gettimeofday(&fin, NULL);
        printf("Tiempo: %f\n", ((fin.tv_sec * 1000000 + fin.tv_usec) - (ini.tv_sec * 1000000 + ini.tv_usec)) * 1.0 / 1000000.0);
        free(grey_image_filename);
    }

    return 0;
}
