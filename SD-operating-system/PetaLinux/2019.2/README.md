PetaLinux build guide
=====================

This guide is created to walk you through the installation process of the operating system PetaLinux, in order to boot it from a SD card. The procedure followed in this guide considers the use of a ZedBoard, which we want to be able to use with the Xilinx software.

The guide is divided in two main parts, which includes the installation of the Vivado SDK and the cofiguring of the PetaLinux project for ZedBoard. It is important to note that the versions for both PetaLinux and Vivado should be the same. We will be working with version 2019.2 in this guide.

Table of contents:
- [Vivado SDK](#vivado-sdk)
   - [Vivado Design Suite and Vitis IDE Installation](#vivado-design-suite-and-vitis-ide-installation)
   - [Xilinx Runtime (XRT) Installation](#xilinx-runtime-(xrt)-installation)

Vivado SDK
----------
First of all, it is neccesary to install the Vivado SDK. The software can be dowloaded from the Xilinx webpage, where it's neccesary to create an account in order to download any packages. To install both the Vivado and Vitis IDE, [click here](https://www.xilinx.com/support/download.html). The page gives you access to an unified installer for both softwares. The software can be installed to any directory.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Vivado%20SDK%20download.png)




### Vivado Design Suite and Vitis IDE Installation

Open the terminal of the computer and access the directory where you've previously saved the downloaded file with the *'cd'* command.

Example:
> cd dl

Enable the exectuion of this file with the following command, and execute it:

> chmod +x 'file_name'.bin
>
> ./ 'filename'.bin

The last command starts runnin the installer of the SDK. On the first pop-up window, some information about the operating systems that support this software is handed out. Your Ubuntu release has to be 16.04.5 or higher in order to install the 2019.2 version.
Click next and in the next window the information of your account will be required.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Vivado%20SDK%20Installation%201.png)

If you want download the software and installe it later with no internet access select the option *'Download full image'*, otherwise click next and accept the terms and conditions of the software.

On the new window, you can select what software you want to install. Select Vitis and click next.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Vivado%20SDK%20Installation%202.png)

Now, you'll be able to customize the download. In this case we are going to leave the following configuration, where we are installing both Vivado and Vitis software, and also the devices for custom platforms of the Zynq-7000, which is the chip we are using. It's okay to download all the packages, but it takes up quite a lot of space, so is better to select what you need, as you can add other packages later.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Vivado%20SDK%20Installation%203.png)

Note that, for Linux, the cable drivers aren't installed. Follow the UG973 isntructions to install them. The document that we are using is the [*Vivado Design Suite User Guide, page 44*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug973-vivado-release-notes-install-license.pdf). There is a copy of this document uploaded in this folder. To install the cable drivers, enter the following instructions in the command window:

> ${vivado_install_dir}/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers

Modify the *${vivado_install_dir}* with the directory of the data folder in your computer.



### Xilinx Runtime (XRT) Installation
