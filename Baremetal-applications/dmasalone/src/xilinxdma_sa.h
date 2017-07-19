/*
 * xilinxdma_sa.h
 *
 *  Created on: 08/03/2017
 *      Author: lucia
 */

#ifndef XILINXDMA_SA_H_
#define XILINXDMA_SA_H_


/************************** Include Files *****************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sleep.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xil_io.h"
#include "xil_exception.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xscugic.h"
#include "xdmaps_mod.h"

/************************** Constant Definitions *****************************/
#define DMA_DEVICE_ID 			XPAR_XDMAPS_1_DEVICE_ID
#define INTC_DEVICE_ID			XPAR_SCUGIC_SINGLE_DEVICE_ID

#define DMA_DONE_INTR_0			XPAR_XDMAPS_0_DONE_INTR_0
#define DMA_DONE_INTR_1			XPAR_XDMAPS_0_DONE_INTR_1
#define DMA_DONE_INTR_2			XPAR_XDMAPS_0_DONE_INTR_2
#define DMA_DONE_INTR_3			XPAR_XDMAPS_0_DONE_INTR_3
#define DMA_DONE_INTR_4			XPAR_XDMAPS_0_DONE_INTR_4
#define DMA_DONE_INTR_5			XPAR_XDMAPS_0_DONE_INTR_5
#define DMA_DONE_INTR_6			XPAR_XDMAPS_0_DONE_INTR_6
#define DMA_DONE_INTR_7			XPAR_XDMAPS_0_DONE_INTR_7
#define DMA_FAULT_INTR			XPAR_XDMAPS_0_FAULT_INTR

#define TEST_ROUNDS	1	/* Number of loops that the Dma transfers run.*/


/************************** Variable Definitions *****************************/

/************************** Function Prototypes *****************************/

int XDmaSA_Init(XScuGic *GicPtr, XDmaPs *DmaPtr, u16 DeviceId);
void XDmaSA_Program(int *Src, int *Dst, size_t DmaLength, XDmaPs_Cmd* DmaCmd);
int SetupInterruptSystem(XScuGic *GicPtr, XDmaPs *DmaPtr);
void DmaDoneHandler(unsigned int Channel, XDmaPs_Cmd *DmaCmd,
			void *CallbackRef);


#endif /* XILINXDMA_SA_H_ */
