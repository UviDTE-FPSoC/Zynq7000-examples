#Name of the module
obj-m := DMA_PL330.o
#Files composing the module
DMA_PL330-objs :=  DMA_PL330_LKM.o alt_dma.o alt_dma_program.o 

all:
	make -C ~/LnxKernel/linux-digilent/ M=$(PWD) modules

clean:
	make -C ~/LnxKernel/linux-digilent/ M=$(PWD) clean
