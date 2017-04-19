################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/main.c \
../src/main_functions.c \
../src/pmu.c \
../src/xdmaps_mod.c \
../src/xil_cache_lucia.c \
../src/xilinxdma_sa.c 

OBJS += \
./src/main.o \
./src/main_functions.o \
./src/pmu.o \
./src/xdmaps_mod.o \
./src/xil_cache_lucia.o \
./src/xilinxdma_sa.o 

C_DEPS += \
./src/main.d \
./src/main_functions.d \
./src/pmu.d \
./src/xdmaps_mod.d \
./src/xil_cache_lucia.d \
./src/xilinxdma_sa.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../salonedma_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


