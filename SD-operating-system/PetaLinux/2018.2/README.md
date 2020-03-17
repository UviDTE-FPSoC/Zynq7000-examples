Petalinux 2018.2 in Trenz TE0703-05 board
=========================================

This folder contains hardware information and instructions to obtain a bootable Petalinux SD card for the [TE0720-03-1CFA-S Starter Kit](https://shop.trenz-electronic.de/en/TE0720-03-1CFA-S-TE0720-03-1CFA-S-Starter-Kit). This kit contains a Trenz TE0720 Gigazee board and a TE0703 carrier board.

The folder *test_board*: reference files provided by Trenz to test the board. Downloaded from [the TE0720 downloads page](https://shop.trenz-electronic.de/de/Download/?path=Trenz_Electronic/Modules_and_Module_Carriers/4x5/TE0720/Reference_Design/2018.2/test_board). The version downloaded is the one for Xilinx tools v2018.2 and without prebuilt images. Using this files and explanations below should be possible to build a customized bootable SD Petalinux card for TE0720 board. The version with prebuilt images enables you to test the board faster since contains the compiled hardware and software files to directly create the SD card.

Hardware Description
--------------------

#### Trenz TE0720 GigaZee

**Features**

[TE0702](https://wiki.trenz-electronic.de/display/PD/TE0720+-+GigaZee) is a Zynq-7000 industrial grade board which includes:

* Xilinx Zynq-7000 chip. Exact device: XC7Z020-1CLG484C. It contains:
    * ARM dual-core Cortex-A9 MPCore
    * Mid-range Artix-7 FPGA.
* 10/100/1000 tri-speed Gigabit Ethernet  
* USB 2.0 high speed ULPI
* 32-Bit-wide 1 GByte DDR3 SDRAM
* 8 GByte e.MMC
* 32 MByte Quad SPI Flash memory
* 152 FPGA I/O's (75 LVDS pairs possible) and 14 MIO's available on board-to-board connectors
* 3 user LEDs

Full specs [here](https://wiki.trenz-electronic.de/display/PD/TE0720+TRM#TE0720TRM-Overview).

**Boot Process**

Supports 2 boot processes, controlled by MODE input signal from the B2B JM1 connector:

* QSPI: MODE high or open.
* SD Card: Low or connected to ground.

**Oscillators**

* PS-CLK = 33.3333 MHz. Pin name = PS_CLK_500. Zynq SoC PS subsystem main clock.
* OTG-RCLK = 52 MHz. Pin name = REFCLK. USB3320C PHY reference clock.
* ETH-CLK = 25 Mhz. Pin name = 	XTAL_IN. 88E1512 PHY reference clock.

**Pin assignments**

Pin assignments for 4x5 boards can be found [here](https://wiki.trenz-electronic.de/display/PD/4+x+5+SoM+Integration+Guide).


#### TE0703 Carrier Board

Documentation for the TE0703 carrier comming in the starter pack can be found
[here](https://wiki.trenz-electronic.de/display/PD/TE0703).

**Features**

* USB JTAG and UART interface, compatible with Xilinx.
* 4 User LEDs.
* 1 User push button (reset).
* 4 User DIP switches (Enable/disabnle intelligent carrier controller, MIO0, 2 mode bits).
* Micro SD bootable socket.
* USB host connector.
* RJ45 GbE connector.

**Shipping status**

Shipping DIP switches status:

* S2-1 -> ON.  Mode control MC1.
* S2-2 -> ON.  FPGA Access on 0720 module.
* S2-3 -> ON.  FPGA/CPLD access on 0720 module (depending on S2-2).
* S2-4 -> OFF. Boot mode set to QSPI. -> **CHANGE IT TO BOOT FROM SDCARD**



Xilinx Tools Installation
-------------------------

To work with SoC FPGA boards Xilinx provides the following software:

 * Vivado: to develop hardware for the FPGA.
 * Xilinx SDK: To develop applications software (baremetal, RTOS or Linux applications).
 * Petalinux SDK: To compile a customizable Yocto-based linux distribution called Petalinux.

#### Vivado and Xilinx SDK

Steps to install Vivado and Xilinx SDK:

* Download Vivado 2018.2 installer. We install 2018.2 because there are examples for the TE0720 board.
* Run the installer script as administrator (sudo).
* Install Vivado and SDK in /opt/Xilinx.
* Give your user access to /opt/Xilinx.

To run Vivado GUI from terminal:

```
> source /opt/Xilinx/Vivado/2018.2/settings64.sh
> vivado &
```

> You can add the source command at the end of ~/.bashrc so the command runs on terminal start-up.

To run Vivado as a Tcl console:

```
# open Tcl console
> vivado -mode Tcl
# run a specific Tcl file
> vivado -mode batch -source <your_Tcl_script>
```

To run the Xilinx SDK from terminal:

```
> source /opt/Xilinx/Vivado/2018.2/settings64.sh
> xsdk &
```

To uninstall Vivado and SDK

```
sudo /opt/Xilinx/.xinstall/Vivado_2018.2/xsetup -Uninstall
```

Some Vivado documentation:

* Vivado Design Suite User Guide - Getting Started  (UG910)
* Vivado Design Suite User Guide - Using the Vivado IDE (UG893)
* Vivado Design Suite User Guide - I/O and Clock Planning (UG899)
* Vivado Design Suite User Guide - Programming and Debugging (UG908)
* Zynq-7000 All Programmable SoC Software Developers Guide (UG821)

#### Petalinux SDK

Petalinux SDK is used to install Petalinux OS and generate a bootable SD card for Xilinx boards.

Why Linux?? It has a lot of drivers, network, filesystem support, memory management, interprocess communication, portable, free/open source. Petalinux can be embedded in Microblaze, Zynq and Ultrascale.

Install Petalinux tools 2018.2 (same version used for Vivado and SDK).

Install required libraries. In Ubuntu 16.04 LTS:
```
sudo apt-get install gawk chrpath socat autoconf libtool gcc-multilib libncurses-dev libssl-dev xvfb libsdl1.2-dev
```

Create a folder with full privileges for the current user.
```
mkdir ~/petalinux2018.2
```

Install petalinux tools in it:
```
./petalinux-v2018.2-final-installer.run ~/petalinux2018.2/
```

Before running petalinux SDK you must make visible the tools to the console, executing settings.sh:
```
source ~/petalinux2018.2/settings.sh
```

> You can add the source command at the end of ~/.bashrc so the command runs on terminal start-up.


Booting Reference Design
------------------------

This section uses the reference designs provided by Trenz to boot the SD card for the first time.

#### TE Reference Project Delivery

Each TE board has different reference designs for different versions of Vivado and Petalinux tools.

For the TE0720 board, the most simple reference disign is the *test_board* example, available for download [here](https://shop.trenz-electronic.de/de/Download/?path=Trenz_Electronic/Modules_and_Module_Carriers/4x5/TE0720/Reference_Design/2018.2/test_board). There are 2 versions of the project:

* Prebuilt: it comes with prebuilt files to directly mount an SD card, without booting. Very useful to test that the SD-card runs properly.
* No Prebuilt: It does not come wih prebuilt files. You are forced to compile hardware and Petalinux in order to properly boot from SD card.

#### TE Board part files

[TE Board part files doc](https://wiki.trenz-electronic.de/display/PD/TE+Board+Part+Files).

TE modules are available in different assembly options. You need to use different files in Vivado to program the different boards, depending on the FPGA used, the available RAM memory and the board revision.

**Naming convention** for board folders: <major>.<minor>, example 1.0.
Major refers to specific carrier/module combination.
Minor refers to PCB revision.

In AIMEN we are using the TE0720 starter kit with:
* TE0720-03-1F Zynq-7000 micromodule
* TE0703 base board

The different identifiers for the TE0720 board are:
* Product ID: te0720-03-1cf         
* Part name: xc7z020clg484-1 (FPGA chip name in Vivado)
* Board name: trenz.biz:te0720_1c:part0:1.0   
* Sort name: 1cf         
* Zynq flash Type: qspi_single  
* FPGA flash type: s25fl256s-3.3v-qspi-x4-single|SPIx4|32  

The board part files are available in the board_files folder of reference designs. These files can be local to your project or they can be installed in the Vivado repository, so the board appears as available hardware every time a new project is created in Vivado. To install board part files in Vivado follow the [Installation  website](https://wiki.trenz-electronic.de/display/PD/Installation). We decided to use the local approach in this tutorial. It is explained in the next section.


#### Compiling Hardware

Trenz projects are tcl-based projects. The folder organization of the example is explained in [Vivado Project Delivery](https://wiki.trenz-electronic.de/display/PD/Project+Delivery).

The [Reference Design - Getting Started](https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Xilinx+devices#ProjectDelivery-Xilinxdevices-DesignEnvironment:Usage) section in the Vivado Project Delivery page explains the steps needed to compile the hardware:

* Download the reference project .zip file and uncompress it.

* Open the terminal and navigate to the reference design folder.

* Create scripts for Linux with:
  ```
  source _create_linux_setup.sh
  ```

* Press 0 to select minimal setup. The file design_basic_settings.sh is created.

* open *design_basic_settings.sh* file and modify *"export PARTNUMBER=LASTID"* to *"export PARTNUMBER=te0720-03-1cf"* (with no spaces in between).

* Create the gui version of your project. This step prepares all the files needed to compile a hardware project for the board in the vivado folder, and automatically opens vivado. But it also makes visible to the Vivado TCL console an extension of the TCL language with Trenz specific commands:
  ```
  source vivado_create_project_guimode.sh
  ```

* If the project already exists open it in Vivado using other script:
  ```
  source vivado_open_existing_project_guimode.sh
  ```

* Compile bitstream: Compile the hardware using "Generate Bitstream" button in Vivado or using Trenz special commands on TCL console:
  ```
  source vivado_open_existing_project_guimode.sh
  ```

The bitstream was located in our example in ~/vivado-projects/te0720-test_vivado_2018.2/vivado/te0720-test_vivado_2018.2.runs/impl_1/zsys_wrapper.bit.


#### Compile Petalinux

Follow the tutorial in [PetaLinux KICKstart](https://wiki.trenz-electronic.de/display/PD/PetaLinux+KICKstart):

* Create a new petalinux project (project name will be the name of the device in the board console):
  ```
  petalinux-create --type project --template zynq --name <project_name>
  ```

* Go to Vivado and export the hardware to the main folder of the petalinux project just created.

* Import the hardware configuration into Petalinux project. A color menu appears in the terminal and enables the modification of the hardware configuration.
  ```
  cd <project_name>
  petalinux-config --get-hw-description
  ```

* Configure Operating System.  
  ```
  petalinux-config
  ```
  Select *ps7_uart_0* in *Subsystem AUTO Hardware Settings->Serial Settings->Primary stdin/stdout* so the kernel can boot through the USB Serial console of the board. By default the system uses INITRAMFS (RAM file system). This means that when booting, the system copies the root file system to RAM and works from there (the same as in a Ubuntu live pendrive). This means that when the board restarts all files in the file system are lost. To solve this go to *Image Packaging Configuration->Root filesystem type* and change *INITRAMFS* by *SD card*. In this way the OS will use the rootfs partition of the SD card as non volatile root file system (it will work as the "hard drive" of the system). 

* Build petalinux:
    ```
    petalinux-build
    ```

The compiled files can be found in images/linux/. Next step create a bootable BOOT.BIN file also in images/linux:

```
petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga <fpga_top_level>.bit --u-boot
```

This file contains FSBL, U-Boot and bistream in the same file.

Some extra commands:

* To clean compilation process:
  ```
  petalinux-build -x mrproper
  ```

* To change the FPGA part leaving the rest the same (so we do not wait for another compilation):
  ```
  petalinux-package --boot --fsbl ...elf --fpga ...bit uboot
  ```
  The uboot is located at <PROJECT>/images/linux/u-boot.elf

#### Build SD Card

Using GParted setup the following partitions, as recommended by *ug1144-Petalinux Tools Documentation - Reference Guide*:

* 4MB empty at the beginning.
* Partition 1. Format: FAT32. Label: "BOOT". Minimum size: 64MB.
* Partition 2. Format: EXT4. Label "rootfs". Aligned to 4MB for better performance.

We used 1GB for Partition 1 and the rest (around 13G) for partition 2.

Copy the files to their respective partitions:
```
cp images/linux/BOOT.BIN /media/BOOT/
cp images/linux/image.ub /media/BOOT/
sudo tar xvf rootfs.tar.gz -C /media/rootfs
```
BOOT.BIN contains FSBL, UBOOT and bitstream. uimage contains the linux kernel and Device Tree Blob (.dtb file). rootfs.tar.gz is a compressed version of the petalinux file system.

#### Boot the Board

* Insert the SD Card in the SD Card slot.
* Set the S2 switch to:
  * S2-1: ON or OFF.
  * S2-2: ON (Module FPGA JTAG Access).
  * S2-3: ON (Module FPGA/CPLD JTAG Access, depending on S2-2).
  * S2-4: ON (Boot from SD card).
* Power-up the board.
* Open /dev/ttyUSB1 at 115200 bauds using Putty or similar program. You should see text being printed as the boot process executes.
* When prompted to Linux type User:root Password:root to enter in Petalinux.

#### Boot stages

* Boot Rom: It will run a small program that checks the "BootMode" pins to find out the booting device (SD card, NAND Flash, QSPI flash or JTAG). It copies the FSBL to internal RAM and runs the FSBL.

* FSPL: First Stage Boot Loader. Programs the PS and PL. Steps:
  * Initialize PS (PS7_INIT())
  * Program the PL (Bitstream)
  * Load second stage bootloader or baremetal (no OS) application in DDR memory.
  * Jump to baremetal application or second stage bootloader.

> We can create a file called FSBL_HOOKS.C to customize the FSPL booting process.

* U-Boot: Second stage boot loader. Initializes RAM memory. It copies the kernel image to RAM and executes the OS.

* Operating System: the linux distribution boots initializing the two processors, mounts the root file system (typically in SD-Card, but it can be in RAM), detects all the available hardware and loads the corresponding drivers using the information in the device tree blob (.dtb) file.


Software Creation
-----------------

#### Software Creation with Xilinx SDK

The Xilinx SDK is the best way to create software for Petalinux and Baremetal (no OS), because the extra Xilinx tools to configure the project, plus the possibility to debug software.

To create a new application for Petalinux:

* Open Xilinx SDK from Terminal typing:
  ```
  xsdk
  ```

* Select File > New > Application Project to open the New Application Project dialog box.
* Specify a project name in the Project name text box.
* Select linux in *OS Platform* drop-down list.
* Select Cortex A9 in *Processor Type* drop-down list.
* Press next and select a Template to start from.
* Modify the template.
* Press *right click in the project->Build Project* to build the project and generate an executable.

#### Run/Debug in real hardware using Xilinx SDK

First connect the board to the computer:
* Connect the board in an IP address reachable by the computer where SDK is running. Check that they ping each other.

Now create a TCF connection:
* Start the hardware server that connects remote hardware and SDK. Open a new terminal and type (3121 is the port for TCF):
  ```
  hw_server -s tcp::3121
  ```

* In the Target Connections window of the SDK interface, click the Add Target Connection button.
* Select TCF (TCF server is already available in Petalinux by default).
* Name the connection and add the IP of the board. Press Accept.

Now use the TCF connection to Run/Debug the application.
* In the *Run* menu press *Run Configurations* or *Debug Configurations*.
* In  *Xilinx C/C++ application (System Debugger)* create a new connection called *Remote Debugger*.
* In *Target Setup* tab select *Debug Type: Linux Application Debug* and *Connection: <TCF Connection Name>*.
* In *Application* tab select the application you created before in *Project Name* to associate this debugger to the application.
* Press *Apply* to save the changes and the *Run/Debug* to remotely run/debug the application in the board from inside the SDK.  

#### Run/Debug in QEMU using Xilinx SDK

Software can be dubugged withou the real hardware using QUMU, a emulator that enables debugging of applications and drivers for the embedded board in a computer. The [Petalinux Reference Manual](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug1144-petalinux-tools-reference-guide.pdf) explains the details on how to do this.

#### Add applications to Petalinux

Software apps can be added and compiled when compiling Petalinux. To add one of this apps to the petalinux project:

 ```
 petalinux-create -t apps --template c++ --name helloWorld
 ```

 Build petalinux again to add this app to the filesystem. The app is created in components/apps and will be later available in rootfs after compilation of the project.

#### Add libraries to Petalinux

To add support libraries to Petalinux, configure the root file system to include them before Petalinux compilation using the following command:

 ```
 petalinux-config -c rootfs
 ```

 The libraries that are not available can be added precompiled (.so file) or its source added and it will be compiled during Petalinux compilation. Explanation for both methods is included in the [Petalinux Reference Manual](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug1144-petalinux-tools-reference-guide.pdf).
