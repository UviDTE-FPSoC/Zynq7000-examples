DMA_PL330_LKM
============

Introduction
-------------
This Loadable Kernel Module (LKM) moves data between a Linux Application running in user space and a memory or other kind of peripheral in the FPGA using the DMA Controller PL330 available in the PS. For data sizes bigger than 128B this method is faster than moving data with the processor using memcpy(). Moreover the processor is freed during the transfer and can perform other calculations.

The module uses the _char driver_ interface to connect application space and the kernel space. It creates a node in _/dev_ called _**/dev/dma_pl330**_ and support for the the typical file functions is given:   open(), close(), write() and read(). This way reading or writing to an FPGA address using the DMA is as easy as reading or writing into a file. The LKM also exports some variables using sysfs in _**/sys/dma_pl330/**_ to control its behaviour. The application [Test_DMA_PL330_LKM](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-applications/Test_DMA_PL330_LKM) is an example on how to use this driver. 

When moving data the DMAC accesses processor memory through a connection between L3 and SDRAM controller in a non coherent way. To ensure data coherency between processor data and FPGA generated data, the processor must flush the cache before (when DMA writes to processor memory) or after (when DMA  reads from processor memory) DMA access processor memory. To solve this problem the operating system has functions to allocate coherent cached or non-cached bufferes so coherency is always ensured and we don´t have to deal with cache flushsing. These functions are:

 * kmalloc(): allocates a physically contiguous buffer cached in memory. This kind of buffer should be used when accessing through ACP.
 * dma_alloc_coherent(): allocates a physically contiguous buffer in un-cached memory. This kind of buffer should be used when accessing processor memories though L3-to-SDRAM Controller port. When accessing this buffer from processor the operating system is in charge of flushing the cache when needed so data is always retrieved from external SDRAM and therefore is coherent with data written or to be read by the DMA. The Operating System does that for us automatically.

In this driver for Zynq-7000 we are interested only in dma_alloc_coherent() bacause DMA Controller can only access this way to processor memories. However if the FPGA accesses directly to the processor memories using the ACP port, kmalloc() must be used instead. In Cyclone V SoC architecture ACP is connected to L3 instead of to the FPGA so the DMA COntroller has access to it. So in the [version of this module for Cyclone V](https://github.com/UviDTE-FPSoC/CycloneVSoC-examples/tree/master/Linux-modules/DMA_PL330_LKM) an option to move data through ACP is included.

This functions are only available in kernel space and that is the main reason why a LKM is needed to do DMA transfers when using Operating System. The malloc() function available from application space is equivalent to vmalloc() in kernel space. These functions alloc memory that is virtually contiguous but maybe not physically contiguous.

Description of the code
------------------------
The LKM contains the following *variables to control* its behaviour. This variables are exported to the file system using sysfs (in /sys/dma_pl330/):

* prepare_microcode_in_open: PL330 DMA Controller executes a microcode defining the DMA transfer to be done. When prepare_microcode_in_open = 0, the microcode is prepared before every transfer when entering the write() or read() function. When prepare_microcode_in_open = 1 the microcode is prepared when calling the open() function (two microcodes are generated: one for read FPGA and another for write to FPGA). Later when using read() or write() the prepared microcodes are used. This saves the microcode preparation time when doing the transfer. This is important since DMA microcode preparation time goes from DMAC 10% of the transfer time (for data sizes between 128kB and 2MB) to 75% (for data sizes between 2B and 8kB).

* dma_transfer_size: Size of the DMA transfer in Bytes. Only used when prepare_microcode_in_open = 1. Otherwise the size of the DMA transfer is the size passed as argument in read() and write() functions.

* dma_buff_padd: This is the physical address in the FPGA were data is going to be written when using write() or read when using read().

The insertion and removal functions, available in every driver are:

 * DMA_PL330_LKM_init: executed when the module is inserted using _insmod_. It:

 	* initializes the DMA Controller and reserves Channel 0 to be used in DMA transactions, 
 	* ioremaps HPS On-Chip RAM (is is used to store the DMAC microcode),
 	* allocates uncached buffer using dma_alloc_coherent() (to be used when use_acp=0),
 	* exports the control variables using sysfs in /sys/dma_pl330/,
 	* creates the char device driver interface in /dev/dma_pl330/,
 	* and enables PMU to be accessed from user space (the same performed by [Enable_PMU_user_space](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/Enable_PMU_user_space)).
 	
 * DMA_PL330_LKM_exit: executed when using _rmmod_. It reverts all what was done by DMA_PL330_LKM_init so the system remains clean, just exactly the same as before the driver was inserted.

The char device driver interface functions are:
 * dev_open: called when open() is used. It prepares the DMA write and read microcode if prepare_microcode_in_open=1. To prepare the write microcode it uses uncached buffer as source,  dma_buff_padd as destiny and dma_transfer_size as transfer size. To prepare the read microcode destiny and source buffers are swapped.

 * dev_write: when  using write() function the data is copied from the application using _copy_from_user()_ function to  uncached buffer. Later a transfer from the buffer to the memory in the FPGA using the PL330 DMA Controller. If prepare_microcode_in_open=1 the microcode programmed in dev_open is used to perform the transfer. If prepare_microcode_in_open=0 a new microcode is prepared using the size parameter passed in dev_write function as size for the DMA transfer.To program the PL330 transfer, the functions of the Altera´s hwlib were modified to work in kernel space (they are designed for baremetal apps so the modification basically consists in ioremap the hardware addresses of the DMA Controller so the functions for baremetal work inside the virtual memory environment used in the LKM). Altera hwlib functions were used because this driver was first programmed for ALtera´s Cyclone V SOC chip and later migrated to Zynq-7000. Better method to do this driver would have been to use "platform device" API to get information on the DMA from device tree and later use "DMA-engine" API to program the DMA transfer. However those APIs didn´t work and we were forced to do a less generic driver. Probably the DMA-engine options should be activated during compilation of the kernel but we were not able to do it.

 * dev_read: called when using read() to read from the FPGA. It does the same as write in opossite direction. First the DMA transfer copies data from FPGA into the cached or uncached buffer and then this data is copied to application space using _copy_to_user()_.
 
 * dev_release: called when callin the close() function from the application. Does nothing.

Possible improvements: 
 * Lock (when calling dev_open) and unlock (when calling dev_release) so the driver cannot be open more than once at a time.
 * Augment the number of channel used by the DMAC (PL330 has 8 DMA channels that can work simultaneously). One idea could be to use one channel each time an application opens the driver and lock the open when the number of opens reaches 8. This ways up to 8 different applications could be making usage of the DMAC.

Contents in the folder
----------------------
* DMA_PL330_LKM.c: main file containing the code just explained before.
* Modifications to the hwlib functions:
    * alt_dma.c and alt_dma.h: functions to control the DMAC (all the functions not used in our program in alt_dma.c were commented to minimize the errors compiling.).
    *  alt_dma_common.h: few declarations for DMA.
    *  alt_dma_periph_cv_av.h: some macro declarations.
    *  alt_dma_program.c and alt_dma_program.h: to generate the microcode program for the DMAC.
    *  hwlib_socal_linux: All the generic files used in the files for all peripherals (hwlib.h, socal.h, etc.) were not copied to the folder of the driver. Copying this files gives a lot of errors that need long time to fix. So instead of fixing generic files we commented the include lines for generic files in the beginning of the files previously enumerated and copied all macros that these files need into one single file called hwlib_socal_linux.h. This file includes definitions from hwlib.h, alt_rstmgr.h, socal/hps.h, socal/alt_sysmgr.h , alt_cache.h and alt_mmu.h. 
* Makefile: describes compilation process.

Compilation
-------------
To compile the driver you need to first compile the Operating System (OS) you will use to run the driver, otherwise the console will complain that it cannot insert the driver cause the tag of your module is different to the tag of the OS you are running. It does that to ensure that the driver will work. Therefore:

  * Compile the OS you will use. In [tutorials to build a SD card with Operating System](https://github.com/lcostas/Zynq7000-examples/tree/master/SD-operating-system) there are examples on how to compile OS and how to prepare the environment to compile drivers.
  * Prepare the make file you will use to compile the module. The makefile provided in this example is prepared to compile using the output of the [Linaro OS](https://github.com/lcostas/Zynq7000-examples/tree/master/SD-operating-system/Linaro) compilation process. CROSS_COMPILE contains the path of the compilers used to compile this driver. ROOTDIR is the path to the kernel compiled source. It is used by the driver to get access to the header files used in the compilation (linux/module.h or linux/kernel.h in example). Modify these 2 paths to be able to find the compiler and the OS header files of the operating system you are using, in case you are not following Linaro.
  * Open a regular terminal (I used Ubuntu 14.04 to compile Linaro and its drivers), navigate until the driver folder and tipe _make_.
 
The output of the compilation is the file _DMA_PL330.ko_.
    
How to test
-----------
Run the [Test_DMA_PL330_LKM](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-applications/Test_DMA_PL330_LKM) example.
