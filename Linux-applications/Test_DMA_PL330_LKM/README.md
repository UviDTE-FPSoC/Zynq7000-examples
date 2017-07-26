Test_DMA_PL330_LKM
==================

Introduction
-------------
This application tests the [DMA_PL330_LKM](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/DMA_PL330_LKM) kernel module and also shows how to use it. DMA_PL330_LKM is a module that permits application-FPGA transfers using the DMA controller PL330 available in HPS.  It uses character driver interface to communicate to application space. The entry /dev/dma_pl330 is created when the driver is inserted and afterwards the FPGA can be accessed as a file with the regular functions open(), read(), write() and close(). 

In the FPGA should be a memory with space enough for the transfers. For this purpose project with an On-Chip RAM in the FPGA in the [FPGA-hardware folder](https://github.com/lcostas/Zynq7000-examples/tree/master/FPGA-hardware) in this repository can be used.

Description of the code
------------------------
Test_DMA_PL330_LKM first generates a virtual address to access FPGA from application space, using mmap(). This is needed to check if the transfers done by the driver are being done in proper way. After that the driver is configured using a sysfs entry in /sys/dma_pl330/. Lastly the program copies a buffer from application to the FPGA using write() and copies back the content in  the FPGA to the application using the read() function. Both operations are checked and a error message is shown if the transfer went wrong.

The configuration of the module can be controlled with 4 macros on the top of the program:

* DMA_TRANSFER_SIZE: Size of the DMA transfer in Bytes. Only used when PREPARE_MICROCODE_WHEN_OPEN = 1. Otherwise the size of the DMA transfer is the size passed as argument in read() and write() functions.

* DMA_BUFF_PADD: This is the physical address in the FPGA were the module is going to copy data from the application space. When using the  [FPGA_OCR_256K](https://github.com/robertofem/CycloneVSoC-examples/tree/master/FPGA-hardware/DE1-SoC/FPGA_OCR_256K) project this address is 0xC0000000 (0xC0000000 in the processor address space 0x00000000 in the HPS-FPGA bridge address space).

* PREPARE_MICROCODE_WHEN_OPEN: PL330 DMA Controller executes a microcode defining the DMA transfer to be done. When PREPARE_MICROCODE_WHEN_OPEN = 0, the microcode is prepared before every transfer when entering the write() or read() function. When PREPARE_MICROCODE_WHEN_OPEN = 1 the microcode is prepared when calling the open() function (two microcodes are generated: one for read FPGA and another for write to FPGA). Later when using read() or write() the prepared microcodes are used. This saves the microcode preparation time when doing the transfer. This is important since DMA microcode preparation time goes from DMAC 10% of the transfer time (for data sizes between 128kB and 2MB) to 75% (for data sizes between 2B and 8kB).

Contents in the folder
----------------------
* test_DMA_PL330_LKM.c: all code of the program is here.
* Makefile: describes compilation process.

Compilation
-----------
* Install a compiler. In [Linaro Tutorial](https://github.com/lcostas/Zynq7000-examples/tree/master/SD-operating-system/Linaro).
* In this case we used the linaro for Xillinx from and the makefiles sets _CROSS_COMPILE := arm-xilinx-linux-gnueabi-_. You have to change the path of the compiler to point to the name of your compiler if you install a different one.
* Using a terminal navigate to this application folder and type make.

The output of the compilation is the executable Test_DMA_PL330_LKM.
    
How to test
------------
* Configure the FPGA with a hardware project containing a FPGA On-Chip RAM with space enough for doing the transfer.

* Connect the serial console port (the mini-USB port in DE1-SoC) to the computer and open a session with a Serial Terminal (like Putty) at 115200 bauds. Now you have access to the board OS console.
* Copy the [DMA_PL330_LKM](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/DMA_PL330_LKM) module in the SD card and insert it into the kernel using _insmod_ command: 
```bash
  $ insmod DMA_PL330.ko
```
> Remember. The version of the kernel for which the driver is compiled for should be the same running in the board. This implies that you have to compile the OS you are running in the board and compile the driver with the output files from that compilation. In the [tutorials to build a SD card with Operating System](https://github.com/lcostas/Zynq7000-examples/tree/master/SD-operating-system) and in the [DMA_PL330_LKM folder](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/DMA_PL330_LKM) you can find more information about compiling an Operating System and a Loadable Kernel Moduler (LKM) respectively.

* Copy the executable into the SD card and run the application:
 ```bash
  $ chmod 777 Test_DMA_PL330_LKM
  $ ./Test_DMA_PL330_LKM
```
