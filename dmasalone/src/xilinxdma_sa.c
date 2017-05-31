/************************** Include Files *****************************/
#include "xilinxdma_sa.h"

/************************** Include constants *****************************/


/************************** Include variables *****************************/


/******************************************************************************/
/**
 *
 * This function connects the interrupt handler of the interrupt controller to
 * the processor.  This function is seperate to allow it to be customized for
 * each application. Each processor or RTOS may require unique processing to
 * connect the interrupt handler.
 *
 * @param	GicPtr is the GIC instance pointer.
 * @param	DmaPtr is the DMA instance pointer.
 *
 * @return	None.
 *
 * @note	None.
 *
 ****************************************************************************/
int SetupInterruptSystem(XScuGic *GicPtr, XDmaPs *DmaPtr)
{
	int Status;
	XScuGic_Config *GicConfig;

	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	GicConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(GicPtr, GicConfig,
				       GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
			     (Xil_ExceptionHandler)XScuGic_InterruptHandler,
			     GicPtr);

	/*
	 * Connect the device driver handlers that will be called when an interrupt
	 * for the device occurs, the device driver handler performs the specific
	 * interrupt processing for the device
	 */

	/*
	 * Connect the Fault ISR
	 */
	Status = XScuGic_Connect(GicPtr,
				 DMA_FAULT_INTR,
				 (Xil_InterruptHandler)XDmaPs_FaultISR,
				 (void *)DmaPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the Done ISR for all 8 channels of DMA 0
	 */
	Status = XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_0,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_0,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_1,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_1,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_2,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_2,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_3,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_3,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_4,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_4,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_5,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_5,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_6,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_6,
				 (void *)DmaPtr);
	Status |= XScuGic_Connect(GicPtr,
				 DMA_DONE_INTR_7,
				 (Xil_InterruptHandler)XDmaPs_DoneISR_7,
				 (void *)DmaPtr);

	if (Status != XST_SUCCESS)
		return XST_FAILURE;

	/*
	 * Enable the interrupts for the device
	 */
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_0);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_1);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_2);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_3);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_4);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_5);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_6);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_7);
	XScuGic_Enable(GicPtr, DMA_FAULT_INTR);

	Xil_ExceptionEnable();

	return XST_SUCCESS;

}


/************************** Function Prototypes *****************************/

int XDmaSA_Init(XScuGic *GicPtr, XDmaPs *DmaPtr, u16 DeviceId){

	int Status;

	XDmaPs_Config *DmaCfg;

	/*
	 * Initialize the DMA Driver
	 */
	DmaCfg = XDmaPs_LookupConfig(DeviceId);
	if (DmaCfg == NULL) {
		xil_printf("XDMaPs_Example_W_Intr Fail LookupConfigr\n");
		return XST_FAILURE;
	}

	Status = XDmaPs_CfgInitialize(DmaPtr,
				   DmaCfg,
				   DmaCfg->BaseAddress);
	if (Status != XST_SUCCESS) {
		xil_printf("XDMaPs_Example_W_Intr Fail Initialize\r\n");
		return XST_FAILURE;
	}

	Status = SetupInterruptSystem(GicPtr, DmaPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("XDMaPs_Example_W_SetupIntr Fail \r\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;

}

/*void XDmaSA_Program(XScuGic *GicPtr){*/
void XDmaSA_Program(int *Src, int *Dst, size_t DmaLength, XDmaPs_Cmd* DmaCmd){


	memset(DmaCmd, 0, sizeof(XDmaPs_Cmd));

	DmaCmd->ChanCtrl.SrcBurstSize = 4;
	DmaCmd->ChanCtrl.SrcBurstLen = 4;
	DmaCmd->ChanCtrl.SrcInc = 1;
	DmaCmd->ChanCtrl.DstBurstSize = 4;
	DmaCmd->ChanCtrl.DstBurstLen = 4;
	DmaCmd->ChanCtrl.DstInc = 1;
	DmaCmd->BD.SrcAddr = (u32) Src;
	DmaCmd->BD.DstAddr = (u32) Dst;
	DmaCmd->BD.Length = DmaLength;

}

/*****************************************************************************/
/**
*
* DmaDoneHandler.
*
* @param	Channel is the Channel number.
* @param	DmaCmd is the Dma Command.
* @param	CallbackRef is the callback reference data.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void DmaDoneHandler(unsigned int Channel, XDmaPs_Cmd *DmaCmd, void *CallbackRef)
{

	/* done handler */
	volatile int *Checked = (volatile int *)CallbackRef;
	int Status = 1;
	Checked[Channel] = Status;
}

