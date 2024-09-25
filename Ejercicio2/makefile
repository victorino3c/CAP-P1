all: simple2_intinsics simple2

simple2_intinsics:
	gcc -mavx -mfma simple2_intrinsics.c -o simple2_intrinsics

simple2:
	gcc simple2.c -o simple2

script_rendimiento:
	bash rendimiento.sh

clean:
	rm -f simple2_intinsics simple2