Second_counter_PMU
==================

Description
-----------
This example uses a counter in the Performance Monitoring Unit (PMU) timer to measure seconds and build a second counter. It prints the a number each second through the serial console. After 60 seconds the application finishes.

PMU is a coprocessor located very close to the processor in ARM Cortex-A9. It is in charge of gathering statistics from the processor, i.e. the number of  exceptions, divisions by 0, etc. Each processor core has its own PMU. In case of Zynq-7000 the processor has two cores and therefore two PMUs. PMU is not  mapped in the address space of the processor. It is accessed through instructions like the Neon coprocessors.

The PMU has a CPU clock cycle counter that can be used to measure time. To  measure time with PMU is not a good practice because PMU counts cycles from  CPU clock, not time. Therefore if the clock rate of the CPU changes  (i.e. it is reduced to save energy) the time measurement will be wrong.  The advantage of using the PMU is that it measures time very precisely. Therefore if clock rate is stable and we know its rate we can measure time very precisely with it.

This example can be seen as an example on how to access and control PMU. 

To test this program the access permission to PMU from user space must be first enabled using [Enable_PMU_user_space](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/Enable_PMU_user_space) kernel module.  Be aware that if the module enabling PMU is launched in one processor and the application to count seconds is launched in the other the application will not have access to the PMU because the PMU where the module was running was the only PMU activated. To solve this problem the driver can be inserted and removed from the system several times until both PMUs are activated or taskset can be set to force the application to run in the processor where the PMU was activated.

The code of this example can be also directly compiled in a baremetal application because it doesn´t use any characteristic of the Operating System.

Contents in the folder
----------------------
* main.c: entry point of the program. Configures the PMU to 667MHz input clock signal (667MHz is the frequency of the Zynq-7000 processors in Zedboard).
* pmu.c and pmu.h: functions to control the PMU timer.
* Makefile: describes compilation process.

Compilation
-----------
* Install a compiler. In [Linaro Tutorial](https://github.com/lcostas/Zynq7000-examples/tree/master/SD-operating-system/Linaro).
* In this case we used the linaro for Xillinx from and the makefiles sets _CROSS_COMPILE := arm-xilinx-linux-gnueabi-_. You have to change the path of the compiler to point to the name of your compiler if you install a different one.
* Using a terminal navigate to this application folder and type make.

The output of the compilation is the executable Second_counter_PMU.

How to test
-----------
* Copy [Enable_PMU_user_space](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/Enable_PMU_user_space) module and this application into the SD card.
* Insert [Enable_PMU_user_space](https://github.com/lcostas/Zynq7000-examples/tree/master/Linux-modules/Enable_PMU_user_space) and run this application using:
 ```bash
  $ insmod PMU_User_Space_EN.ko
  $ chmod 777 Second_counter_PMU
  $ ./Second_counter_PMU
```
