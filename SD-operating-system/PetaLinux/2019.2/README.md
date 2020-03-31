  PetaLinux build guide
=====================

This guide is created to walk you through the installation process of the operating system PetaLinux, in order to boot it from a SD card. The procedure followed in this guide considers the use of a ZedBoard, which we want to be able to use with the Xilinx software.

The guide is divided in two main parts, which includes the installation of the Vivado SDK and the cofiguring of the PetaLinux project for ZedBoard. It is important to note that the versions for PetaLinux and Vivado SDK should be the same. We will be working with version 2019.2 in this guide.

Table of contents:
- [Vivado SDK](#vivado-sdk)
   - [Vivado Design Suite and Vitis IDE Installation](#vivado-design-suite-and-vitis-ide-installation)
   - [Xilinx Runtime XRT Installation](#xilinx-runtime-xrt-installation)
     - [Source XRT](#source-xrt)
   - [Embedded Platform Installation](#embedded-platform-installation)
- [PetaLinux](#petalinux)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [Bash or Dash](#bash-or-dash)
    - [Source PetaLinux Tools](#source-petalinux-tools)
    - [Creating a Project with the Board Support Package BSP](#creating-a-project-with-the-board-support-package)
    - [Hardware Configuration](#hardware-configuration)
    - [Importing Hardware Configuration](#importing-hardware-configuration)
    - [Build a system image](#build-a-system-image)
    - [Generate the boot image](#generate-the-boot-image)
    - [Configure SD card to boot PetaLinux](#configure-sd-card-to-boot-petalinux)
    - [Boot PetaLinux image on Hardware with an SD card](#boot-petalinux-image-on-hardware-with-an-sd-card)
    - [Configure IP to connect to the board through SSH](#configure-ip-to-connect-to-the-board-through-ssh)
    - [Add libraries to PetaLinux image](#add-libraries-to-petalinux-image)
  - [Connect to the board](#connect-to-the-board)
    - [UART connection](#uart-connection)
    - [SSH connection](#ssh-connection)
    - [Copy a file to the board with SSH](#copy-a-file-to-the-board-with-ssh)

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

`${vivado_install_dir}/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers`

Modify the *${vivado_install_dir}* with the directory of the data folder in your computer.

In our case we used the following commands from the vivado install directory:

```
cd /data/xicom/cable_drivers/lin64/install_script/install_drivers

sudo ./instal_drivers
```



### Xilinx Runtime XRT Installation
The installation of the XRT should be performed if using a chip of the family Zynq UltraScale+ MPSoC-based, as it is implemented as a combination of user-space and kernel driver components. If you are using a chip from another family, it also provides a software interface to Xilinx programmable logic devices.
The steps to install the package are followed from [*Vitis Unified Software Platform Documentation. Embedded Software Development. Page: 19*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1400-vitis-embedded.pdf). There is a copy of this document uploaded in the *"Xilinx Guide"* folder of this repository just in case new versions of the Xilinx guide are uploaded.
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

This includes sourcing the 'settings64.sh' and 'setup.sh' files in the Vitis and Xilinx XRT installation directories, respectively. To avoid needing to type the source commands into the shell every time we want to use the tools, you can add a couple lines to the .bashrc script. To modify this system wide, we will use a text editor, atom, to modify the script. For Ubuntu, the bash.bashrc script is located in the /etc directory. The script can be easily openned with the following command. The 'atom' sentence can be switched for any other text editor installed in the system.

> sudo atom /home/.bashrc

Once the script is opened, add the two commands for sourcing the appropriate files. The path that is now idicated simply outlines where the 'settings.sh' and 'settings64.sh' files are located at.

> source /media/hdd/Xilinx/Vitis/2019.2/settings64.sh
>
> source /opt/xilinx/xrt/setup.sh

![alt text](hhttps://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SourceXRT.png)



### Embedded Platform installation
No embedded platform installation is made as there is no definition for the Zedboard at this particular moment. One of the builds that include the same chip as the Zedboard would be the Zynq-7000 SoC 7C702 evaluation kit. We will try to perform the setup avoiding this installation step.

If any of the possible Embedded Platforms were to be istalled, the following environment variable setup would have to be done.

> export PLATFORM_REPO_PATHS=<'path to platforms'>



PetaLinux
---------
### Installation
In order to install PetaLinux in your device, it is very important to download the same PetaLinux version as the one previously downloaded for the Vivado SDK. In this case, we will download the Petalinux Tools installer by [clicking here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html).

It is also very important to make sure that the file system of the operating system in your computer, Ubuntu 16.04 LTS in this case, hasn't been encrypted. One option to decrypt it would be to reinstall the SO in you computer.
Finally, make sure the PetaLinux installation directory is within `home`, as otherwise you could have permission problems.

Previous to installing PetaLinux, it is neccesary to install a series of tools indicated in the [*Petalinux Tools Documentation. Reference Guide page: 10 *](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf). There is a copy of this document uploaded in the *"Xilinx Guide"* folder of this repository.

The istallation of these tools for an Ubuntu machine can be performed with the following command.
```
sudo apt-get install tofrodos iproute gawk make net-tools libncurses5-dev tftpd zlib1g:i386 libssl-dev flex bison libselinux1 gnupg wget diffstat chrpath socat xterm autoconf libtool tar unzip texinfo zlib1g-dev gcc-multilib build-essential screen pax gzip python
```

Once the installer file has been downloaded, create a directory where you want the PetaLinux Tools to be installed in. It is highly recommended to create this directory in a HDD disk, as installation needs 100 GB of space, although final space used goes down to 20 GB. Once you've created this folder, open a terminal in the directory the installer has been dowloaded to, likely *"Downloads"*, and introduce the following comands to give execution permision for the file and running the installer.

> chmod +x 'name_of_the_file'.run
>
> ./'name_of_the_file'.run {directory}/PetaLinux

In the directory part you shall enter the path to your PetaLinux folder in your computer, for example:

```
./petalinux-v2019.2-final-installer.run /home/PetaLinux
```

The completion of the installation requires the acceptance of the license agreement of the software itself, the WebPACK software and several third party software licenses as well.



### Configuration
PetaLinux configuration is performed following the [*Petalinux Tools Documentation. Reference Guide*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf).

#### Bash or Dash
First of all, Petalinux requires the usage of the 'bash' shell rather than the 'dash'. Bash is the Bourne-Once extra shell. Bash is a full-featured shell acceptable for interactive use. Bash a superset of POSIX efficiency. Dash is the Debian Almquist Shell. Dash implements the Single Unix Spec. Dash is for non-interactive script execution. Dash Only helps POSIX compliant choices.

In order to stablish the bash as default, type on the command line the following.
```
sudo dpkg-reconfigure dash
```

After typing in the command, we are asked if we want to set up the 'dash' as our default shell, and we have to select *'NO'*.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Bash%20configuration.png)



#### Source PetaLinux Tools
The next thing to take care of will be to source the tools for PetaLinux to use within the terminal window. This includes the 'settings64.sh' and 'settings.sh' files in the Vivado and PetaLinux installation directories, respectively. To avoid typing the source commands into the shell every time, you can add a couple lines to the .bashrc script. To modify this system wide, we will use a text editor, atom, to modify the script. For Ubuntu, the bash.bashrc script is located in the /etc directory. The script can be easily openned with the following command. The 'atom' sentence can be switched for any other text editor installed in the system.
```
sudo atom /home/.bashrc
```

Once the script is opened, add the two commands for sourcing the appropriate files. The path that is now idicated simply outlines where the 'settings.sh' and 'settings64.sh' files are located at.
```
source /media/hdd/PetaLinux/settings.sh
source /media/hdd/Xilinx/Vivado/2019.2/settings64.sh
```

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SourcePetaLinux.png)

With the two lines added, save the changes and close the editor.



#### Creating a Project with the Board Support Package BSP
The BSP provides a functioning Linux image for begginers with PetaLinux. In this case, to download the BSP for the Zedboard, [clik here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html).

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/BSP%20download.png)

The download of the BSP will start after identifying your user in the Xilinx web page. Once the download is performed, some aid can be found in the 'PetaLinux Documentation. Reference Guide. Page 16' to correctly install the BSP.

First of all, make sure the previous configuration setup of PetaLinux has been carried out. Open a new terminal and access the directory you want your PetaLinux projects to be saved at, in our case the following.
In order to avoid any kind of future problems, this directory should be created withing your `/home` directory.

```
cd /Desktop/TFM/PetaLinuxProjects
```

Now, run the following command, indicating the location of the BSP file that was just downloaded and making sure you uncompress this file first.

> petalinux-create -t project -s <'path-to-bsp'>


In our case:

```
petalinux-create -t project -s /media/hdd/dl/avnet-digilent-zedboard-v2019.2-final.bsp
```

If you were to create a fresh project, without using a BSP, you type in the following command.

> petalinux-create --type project --template zynq --name test_01

The type should not be changed, the template has to be the adecuate one for your board and finally the name can be chosen by you as well. This command though simply provides a folder structure for the projects. The actual build to use PetaLinux would have to be created by the user.

##### Hardware Configuration
First of all, it is neccesary to create a hardware configuration, which later you will have to export into a .xsa file. If you are using a BSP, in this guide, the Zedboard BSP, this file is created by default. You can find it in the following directory:

> < PetaLinux_project_directory >/project-spec/hw-description/system.xsa


In our case, this directory would be:

```
/home/fcarp/Desktop/TFM/PetaLinuxProjects/avnet-digilent-zedboard-2019.2/project-spec/hw-description/system.xsa
```



#### Importing Handware Configuration
From the PetaLinux project directory, run the following comand, giving the path to the .xsa file.

> petalinux-config --get-hw-description=< path-to-directory-containing-hardware description-file >

In our case the directory we open the terminal on and the command are as follows.

```
cd home/fcarp/Desktop/TFM/PetaLinuxProjects/avnet-digilent-zedboard-2019.2/

petalinux-config --get-hw-description=project-spec/hw-description/
```

There is a problem though, as when running this command in the PetaLinux Project directory, the terminal is not able to find the 'system.xsa' file. After reviewing the `<directory_PetaLinux_projects_are_saved>/project-spec/hw-description/system.xsa` directory, it turned out that the file had been erased.

In the case this happens to you, we recomend to make a copy of the 'system.xsa' file, and paste it inside the following directory.

> < directory_PetaLinux_projects_are_saved >/project-spec/

If we now run the config command again, the terminal won't release the previous error.
```
petalinux-config --get-hw-description=project-spec/
```

After executing the command, the following window is opened, and we have to select the 'Subsystem AUTO Hardware Settings'. For additional information of the 'Subsystem AUTO Hardware Settings' checkout [Petalinux Tools Documentation. Reference Guide. Page 99](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf).

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/PetaLinux%20configuration%201.png)

After pressing the enter key, the configuration might take several minutes.



#### Build a system image
In the project directory, type in the following command.

```
petalinux-build
```



#### Generate the boot image
This command should be run in the same directory than the previous, and it might take a bit of time as well. The last step would be to run the next command, and after its execution you should have the BOOT.bin and U-boot files ready to go.

```
petalinux-package --boot --fsbl <FSBL image> --fpga <FPGA bitstream> --u-boot
```

In order to correctly fill in the fields `FSBL image` and `FPGA bitstream`, we derive to the [PetaLinux Tools Documentation. Command Line Reference Guide. Page 20](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1157-petalinux-tools-command-line-guide.pdf). The following images highlingth the options that have to be selected according to the use of the zedboard. The command line for our case would be the following.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/PetaLinux%20configuration%202.png)

```
petalinux-package --boot --force --fsbl ./images/linux/zynq_fsbl.elf --fpga ./images/linux/system.bit --u-boot
```

The `/images/linux/` is in the directory created by the command `petalinux-create` command, in this case, `/home/fcarp/Desktop/TFM/PetaLinuxProjects/avnet-digilent-zedboard-2019.2/`.



#### Configure SD card to boot PetaLinux
First of all, we have to create two partitions in the SD card. In order to do this, we have used the utility fdisk. It is highly recommended though to use GParted if you are using a Linux machine, as it simplifies and speeds up the task.
 First of all we are going to see a list of all the disks in the device with the following comand.

 `sudo fdisk -l`

 ![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%201.png)

The SD, in our case, is 16 GB, and it is identified as /dev/sdc. Now we have to enter the command mode in that disk.

`sudo fdisk /dev/sdc`

Inside the command mode, if we press p, we can print a table with the partitions of the card. In this case there is only one partition.

To delete a partition, we would type the command d, and afterwards the number of the partition. In this case, as there is only one partition, we don't have to enter the number.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%202.png)

To create a partition, we type the command n. In this case, as we are only going to have two partitions, we are going to create two primary partitions, p.	 The first one is going to have 1 GB of space. In order to create we have to indicate is a primary partition, p; specify the number, 1; where the partition starts, default; and the size of the partition, 1 GB (+1G).

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%203.png)

The second partition is created as shown in the next image.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%204.png)

The second partition has a size of 13.9 GB.

We now have to specify the type of the partition. In this case, we see that both partitions have a Linux type. Partition sdc 1 has to be type FAT32, as indicated in the [Petalinux Tools Documentation. Reference Guide. Page 40](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf).

In order to change the type, we put in the command line t; the number of the partition, 1; and the type we want to stablish, b. To see a list with all the available types, type in L.

Now we can see that the type of the first partition has been switched to 'W95 FAT32'.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%205.png)

The second partition we leave it as Linux type. Once we have the partitions, we write the changes typing w.

Now, we have to format the first partition, /dev/sdc1, as FAT; and the second parition, /dev/sdc2, as ext4. In order to do this, we type in the next commands.

`sudo mkfs.fat /dev/sdc1`

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%206.png)

`sudo mkfs.ext4 /dev/sdc2`

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%207.png)

To check if the partitions were correctly formated, we type the following.

`lsblk -f`

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%208.png)

Now, we change the label of the partitions, specifying BOOT for the first one and RootFS for the second one, using the following commands.

```
sudo fatlabel /dev/sdc1 BOOT

sudo e2label /dev/sdc2 RootFS
```

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%209.png)

The files that we now have to save on each partition are specified in [Petalinux Tools Documentation. Reference Guide. Page 65](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf).

In order to boot PetaLinux with the SD card, we need to make a couple of changes to the configuration. Get into the PetaLinux project directory, and insert the following comands.

```
cd /home/fcarp/Desktop/TFM/PetaLinuxProjects/avnet-digilent-zedboard-2019.2/

petalinux-config
```

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%2010.png)

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%2011.png)

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/SD%20card%20setup%2012.png)

Exit configuration menu and save the settings. Build and generate the boot image.

```
petalinux-build

petalinux-package --boot --force --fsbl ./images/linux/zynq_fsbl.elf --fpga ./images/linux/system.bit --u-boot
```

Extract the 'rootfs.tar.gz' file present in the /images/linux directory of your PetaLinux project. This step is specified in the Xilinx documentation but you probably can skip it.

```
cd images/linux

tar xvf rootfs.tar.gz
```

The final steps are to copy several files into the partitions previously created. Enter the directory of your PetaLinux project with the terminal. Once in the directory, copy to the BOOT partition the BOOT.bin file and the image.ub file. This second file contains the device tree and the kernel image files.

```
cp images/linux/BOOT.BIN /media/fcarp/BOOT/

cp images/linux/image.ub /media/fcarp/BOOT/

cp images/linux/boot.scr /media/fcarp/BOOT/
```

Copy the rootfs.tar.gz file to the RootFS partition, and extract the file system.bit.

```
cd images/linux

sudo tar xvf rootfs.tar.gz -C /media/fcarp/RootFS

```

> *NOTE*: The previous commands copy this files to the previously created partitions, which are accesible from the /media/fcarp/ directory in our case. This directory can change on other devices.



#### Boot PetaLinux image on Hardware with an SD card
The procedure is specified in [Petalinux Tools Documentation. Reference Guide. Page 41](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf).

Connect the Zedboard to the power and to the computer through the serial port with the micro USB cable.

Before powering on the board, set up the SD boot mode with the MIO Zedboard bank, as shown in table 1 in the ZedBoard manual, table 2 in the Zynq 7000 chip manual and in the figure.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Boot%20PetaLinux%201.png)

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Boot%20PetaLinux%202.png)

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Boot%20PetaLinux%203.png)



#### Configure IP to connect to the board

The configuration of an IP address to directly connect to the board to your computer is really easy. First of all, you need to connect to the board through an UART connection, as explained [here](#uart-connection). Once you've entered the username and pasword, with the following command you will setup an IP in your board for the eth0 interface.

```
ifconfig eth0 192.168.0.1 netmask 255.255.255.0
```

In the case you don't want to always have to type in this command, you can create a *.sh* file with the previous command typed in it. After this you would only have to copy this file to the board using an IP connection as shown [here](#copy-a-file-to-the-board-with-ssh). Note while the *.sh* is not in the board you have to manually set up the IP, as shown before.

Once the *.sh* file is copied to the board, next time you boot it, to setup the IP you only have to access the directory your file is stored at and run the following command.

```
./<file_name>.sh
```



#### Add libraries to PetaLinux image

The addition of supported libraries is done with the following command:

```
petalinux-config -c rootfs
```

The libraries that are not available can be added precompiled (.so file) or its source added and it will be compiled during Petalinux compilation.



### Connect to the board

This section of the guide is focused on showing some of the different processes you could use to connect to the board running PetaLinux through an SD card.



#### UART connection

This example was carried out using a ZedBoard, which uses a Zynq-7000 chip from Xilinx. In order to connect to the board, we used a computer running Ubuntu 18.04 LTS with the software `Putty` installed. It is also neccesary to have the power cable for the board and a micro-usb cable connected to the UART connector in the board, which in this case is the *J14* connector. The image shows how to easily make this connections.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Boot%20PetaLinux%203.png)

In order to use `Putty`, we need to know what computer USB port is the board being connected to. The easiest way arroud to do this is accessing the following directory with your computer's console and running the following command.

```
cd /dev/

ls
```

The `ls` command should print all the ports within this directory. Now, power on the board, and connect it to one of the USB ports of the computer. Once this is done, run the `ls` command again. Now, the command should print one additional name. This would be the USB's port name. In our case, the name of the USB port would be `ttyACM0`.
You can now power off the board and open `Putty`. We configure the connection as shown in the next image, selecting a serial connection, with a baud rate of 115200 and the directory where the board is connected to `/dev/ttyACM0`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/Putty_Serial.png)

Once the configuration is set, power on the board, making sure it is correctly connected to the computer, and click the *Open* button. If there is any kind of problem open Putty again and repeat the proccess a couple of times until you get a console window opened. I you still cannot open the connection, you might have to go to a new console, and open putty using the root permissions.

```
sudo putty
```

After this, repeat the previous process. Once the connection is done, you should see the board booting. If you just see a black console, press any key and type in `boot`. After this the board should reboot.

Once the board has correctly booted, it'll ask for the user name `root` and the pass `root` as well.
The next picture ilustrates the result you should get if connected properly.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/UART_console.png)



#### SSH connections

The first step to establish a SSH connection with the board is to configure an IP address for the board, as shown [here](#configure-ip-to-connect-to-the-board).
Once the board is setup, you have to go to your network settings, and establish a manual IPv4 as shown in the following figure.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/Zynq7000-examples/master/SD-operating-system/PetaLinux/2019.2/GuideImages/ethernet_connection.png)

As you can see, the netmask is the same given to the board and the IP has to be in the same range as the one assigned to the board.

Once the network is applied, you can ping the board to see if you can connect.

```
ping 192.168.0.1
```

If the connection works, the last step would be to create the SSH connection. You can use `PuTTy` or other software. We are directly going to create the connection through the terminal typing in the following.

```
ssh root@192.168.0.1
```

After this, you will get asked the username, which is `root` and the password, which is the same.



#### Copy a file to the board with SSH

Previously, you have to create an SSH connection as shown [here](#ssh-connection).
Now, open a new terminal and introduce the follwing command changing the file directory you want to copy for yours and introducing the IP of your board.

```
scp -r <file_directory>/file.* root@<your_board_IP>
```

As an example we have copied the following file to our board.

```
scp -r /media/arroas/HDD/MinhasCousas/EEI/Mestrado/2º_Curso/TFM/Zynq7000-examples/Useful-scripts/ip_address_assign.sh root@192.168.0.1:~/
```

This command copies the file ip_address_assign.sh to the /home/root directory of the board.
