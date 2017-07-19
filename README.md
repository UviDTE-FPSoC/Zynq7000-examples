zedboardp0
==========

This repository is saving zedboard projects:

* **Baremetal-applications**: Stand-alone (No Operating System) projects.
	* dmasalone: time measurement of DMA transfers between uP and FPGA.

* **Linux-applications**: 
	* Test_DMA_PL330_LKM: Tests if the DMA_PL330_LKM works properly and shows how to use it.

* **Linux-modules**:
	* DMA_PL330_LKM_basic: stand-alone module that makes a data transfer using the PL330 DMAC (available in HPS) when inserted into the operating system. It can be configured to move data between: FPGA memory, HPS On-chip RAM and uncached buffer in processor´s RAM. It is a complete example that can be used as starting point for developing a DMA module for a specific application.
	* DMA_PL330_LKM: module to make transfers between an application and the FPGA using PL330 DMAC. It uses char device driver interface to copy the data from application to a uncached or cached (through ACP) buffer in driver´s memory space. Later it uses PL330 DMAC to copy that buffer to FPGA. A /dev/dma_pl330 entry is created so writing in the FPGA is so easy as writing to a file. Sysfs entries in /sys/dma_pl330 permit the driver to be configured.
