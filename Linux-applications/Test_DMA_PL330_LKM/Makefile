#
TARGET = test_DMA_PL330_LKM

#
CROSS_COMPILE := arm-xilinx-linux-gnueabi-
CFLAGS = -g -Wall  #-I ${SOCEDS_DEST_ROOT}/include
LDFLAGS =  -g -Wall
CC = $(CROSS_COMPILE)gcc
ARCH= arm

build: $(TARGET)

$(TARGET): test_DMA_PL330_LKM.o
	$(CC) $(LDFLAGS)   $^ -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~

