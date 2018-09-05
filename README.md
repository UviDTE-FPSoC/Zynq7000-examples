Zynq-7000 examples
==================

Examples using the FPSoC chip [Zynq-7000](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html).
All these examples were tested on Zedboard. However most of them are easily ported
to other boards including Zynq-7000 chips because they do not interact with the
hardware in the board.

<p align="center">
  <img src="https://github.com/lcostas/Zynq7000-examples/raw/master/Zynq7000.png" width="450" align="middle" alt="Cyclone V SoC simplified block diagram" />
</p>

This repository contains:

* **Baremetal-applications**: Stand-alone applications without Operating System.

* **FPGA-hardware**: Vivado projects describing the FPGA hardware needed in some of the examples.

* **Linux-applications**:
	* Second_counter_PMU: This example uses a counter in the Performance Monitoring Unit (PMU) timer to measure seconds and build a second counter. It stands as an example on how to use PMU to measure time.
	* Test_DMA_PL330_LKM: Tests if the DMA_PL330_LKM works properly and shows how to use it.

* **Linux-modules**:
	* DMA_PL330_LKM_basic: stand-alone module that makes a data transfer using the PL330 DMAC (available in HPS) when inserted into the operating system. It can be configured to move data between: FPGA memory, HPS On-chip RAM and uncached buffer in processor´s RAM. It is a complete example that can be used as starting point for developing a DMA module for a specific application.
	* DMA_PL330_LKM: module to make transfers between an application and the FPGA using PL330 DMAC. It uses char device driver interface to copy the data from application to a uncached or cached (through ACP) buffer in driver´s memory space. Later it uses PL330 DMAC to copy that buffer to FPGA. A /dev/dma_pl330 entry is created so writing in the FPGA is so easy as writing to a file. Sysfs entries in /sys/dma_pl330 permit the driver to be configured.

* **SD-operating-system**: It explains how to build an SD card with Operating System from scratch.
  Currently the OS that have been tested are:
	* Linaro Ubuntu Distribution.
