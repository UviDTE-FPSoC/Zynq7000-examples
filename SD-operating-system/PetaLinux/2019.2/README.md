PetaLinux build guide
=====================

This guide is created to walk you through the installation process of the operating system PetaLinux, in order to boot it from a SD card. The procedure followed in this guide considers the use of a ZedBoard, which we want to be able to use with the Xilinx software.

The guide is divided in two main parts, which includes the installation of the Vivado SDK, installation of the Vitis AI package and the cofiguring of the PetaLinux project for ZedBoard. It is important to note that the versions for PetaLinux, Vivado SDK and Vitis AI should be the same. We will be working with version 2019.2 in this guide.

Table of contents:
- [Vivado SDK](#vivado-sdk)
   - [Vivado Design Suite and Vitis IDE Installation](#vivado-design-suite-and-vitis-ide-installation)
   - [Xilinx Runtime XRT Installation](#xilinx-runtime-xrt-installation)
     - [Source XRT](#source-xrt)
   - [Embedded Platform Installation](#embedded-platform-installation)
- [Vitis AI](#vitis-ai)

Vivado SDK
----------
First of all, it is neccesary to install the Vivado SDK. The software can be dowloaded from the Xilinx webpage, where it's neccesary to create an account in order to download any packages. To install both the Vivado and Vitis IDE, [click here](https://www.xilinx.com/support/download.html). The page gives you access to an unified installer for both softwares, although Vitis AI is not included. The software can be installed to any directory.

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

Note that, for Linux, the cable drivers aren't installed. Follow the UG973 isntructions to install them. The document that we are using is the [*Vivado Design Suite User Guide, page 44*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug973-vivado-release-notes-install-license.pdf). There is a copy of this document uploaded in the *"Xilinx Guide"* folder of this repository. To install the cable drivers, enter the following instructions in the command window:

> ${vivado_install_dir}/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers

Modify the *${vivado_install_dir}* with the directory of the data folder in your computer.



### Xilinx Runtime XRT Installation
The installation of the XRT should be performed if using a chip of the family Zynq UltraScale+ MPSoC-based, as it is implemented as a combination of user-space and kernel driver components. If you are using a chip from another family, it also provides a software interface to Xilinx programmable logic devices.
The steps to install the package are followed from [*Vitis Unified Software Platform Documentation. Embedded Software Development. Page: 19*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1400-vitis-embedded.pdf). There is a copy of this document uploaded in the *"Xilinx Guide"* folder of this repository.
To download the DEV file for Linux 16.04 [click here](https://www.xilinx.com/bin/public/openDownload?filename=xrt_201920.2.3.1301_16.04-xrt.deb). If you have other Linux versions, go to the documentation page before mentioned.

Once the packet has been downloaded, type in the following command to install it.

> sudo apt install <'deb-dir'>/<'xrt_filename_OS'>.deb
>
>> *<'deb-dir'>* : Path to the directory where the '.deb' file was downloaded to
>
>>*<'xrt_filename_OS'>* : Name of the file

In our case, the full command line would look like this.

> sudo apt install /media/hdd/dl/xrt_201920.2.3.1301_16.04-xrt.deb

#### Source XRT
The next thing to take care of will be to set up the environment to run the Vitis Software Platform. The set up procedure is followed from the [*Vitis Unified Software Platform Documentation. Embedded Software Development. Page: 21*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1400-vitis-embedded.pdf).

This includes setting up the 'settings64.sh' and 'setup.sh' files in the Vitis and Xilinx XRT installation directories, respectively. To avoid needing to type the source commands into the shell every time we want to use the tools, you can add a couple lines to the .bashrc script. To modify this system wide, we will use a text editor, atom, to modify the script. For Ubuntu, the bash.bashrc script is located in the /etc directory. The script can be easily openned with the following command. The 'atom' sentence can be switched for any other text editor installed in the system.

> sudo atom /etc/bash.bashrc

Once the script is opened, add the two commands for sourcing the appropriate files. The path that is now idicated simply outlines where the 'settings.sh' and 'settings64.sh' files are located at.

> source /media/hdd/Xilinx/Vitis/2019.2/settings64.sh
>
> source /opt/xilinx/xrt/setup.sh

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Source%20XRT.png)



### Embedded Platform installation
No embedded platform installation is made as there is no definition for the Zedboard at this particular moment. One of the builds that include the same chip as the Zedboard would be the Zynq-7000 SoC 7C702 evaluation kit. We will try to perform the setup avoiding this installation step.

If any of the possible Embedded Platforms were to be istalled, the following environment variable setup would have to be done.

> export PLATFORM_REPO_PATHS=<'path to platforms'>



Vitis AI
--------
