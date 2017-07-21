CROSS_COMPILE := arm-xilinx-linux-gnueabi-

CC = $(CROSS_COMPILE)gcc
ARCH= arm
LDFLAGS =  -g -Wall
Second_counter: main.o pmu.o
	$(CC) -o Second_counter_PMU main.o pmu.o

main.o: main.c pmu.h
	$(CC) -c main.c

pmu.o: pmu.c pmu.h
	$(CC) -c pmu.c
