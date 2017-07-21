MODULES := PMU_User_Space_EN.o

#guest architecture
ARCH := arm

#compiler
CROSS_COMPILE := arm-xilinx-linux-gnueabi-

obj-m := $(MODULES)

#path to the compiled kernel
ROOTDIR := ~/LnxKernel/linux-digilent/

MAKEARCH := $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

all: modules
modules:
	$(MAKEARCH) -C $(ROOTDIR) M=${shell pwd} modules

clean:
	$(MAKEARCH) -C $(ROOTDIR) M=${shell pwd} clean
