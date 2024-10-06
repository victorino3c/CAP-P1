CC = gcc
LIBS = -lm
LIB_DIR = 
FLAGSV = -O3 -fno-tree-vectorize -mavx -mfma -march=native -Wall -D_GNU_SOURCE
FLAGS = -O3 -ftree-vectorize -mavx -mfma -march=native -fwhole-program -Wall -D_GNU_SOURCE

.PHONY: clean all

all: greyScale greyScaleAV greyScaleModified greyScaleModifiedAV greyScaleVectorized clear

greyScale: greyScale.c stb_image_write.h stb_image.h
	$(CC) $(FLAGSV) -std=gnu99 $(LIB_DIR) -o $@ greyScale.c $(LIBS)

greyScaleAV: greyScale.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ greyScale.c $(LIBS)

greyScaleModified: greyScaleModified.c stb_image_write.h stb_image.h
	$(CC) $(FLAGSV) $(LIB_DIR) -o $@ greyScaleModified.c $(LIBS)

greyScaleModifiedAV: greyScaleModified.c stb_image_write.h stb_image.h
	$(CC) $(FLAGS) $(LIB_DIR) -o $@ greyScaleModified.c $(LIBS)

greyScaleVectorized: greyScaleVectorized.c stb_image_write.h stb_image.h
	$(CC) $(FLAGSV) -std=gnu99 $(LIB_DIR) -o $@ greyScaleVectorized.c $(LIBS)

stb_image.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

stb_image_write.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

clean:
	rm -f *.o *.dat *~ greyScale greyScaleAV greyScaleModified greyScaleModifiedAV greyScaleVectorized
	
clear:
	rm -f *.o *~
