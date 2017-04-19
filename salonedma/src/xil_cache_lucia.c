/******************************************************************************
*
* Copyright (C) 2010 - 2015 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
*
* @file xil_cache_lucia.c
*
* Contains enable function for the ARM L2 cache*/

/***********Include Files *********************************/

#include "xil_cache.h"
#include "xil_cache_l.h"
#include "xil_io.h"
#include "xpseudo_asm.h"
#include "xparameters.h"
#include "xreg_cortexa9.h"
#include "xl2cc.h"
#include "xil_errata.h"
#include "xil_exception.h"

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/


#ifdef __GNUC__
	extern s32  _stack_end;
	extern s32  __undef_stack;
#endif

/****************************************************************************
*
* Access L2 Debug Control Register.
*
* @param	Value, value to be written to Debug Control Register.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
#ifdef __GNUC__
static inline void Xil_L2WriteDebugCtrl(u32 Value)
#else
static void Xil_L2WriteDebugCtrl(u32 Value)
#endif
{
#if defined(CONFIG_PL310_ERRATA_588369) || defined(CONFIG_PL310_ERRATA_727915)
	Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_DEBUG_CTRL_OFFSET, Value);
#else
	(void)(Value);
#endif
}

/****************************************************************************
*
* Perform L2 Cache Sync Operation.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
#ifdef __GNUC__
static inline void Xil_L2CacheSync(void)
#else
static void Xil_L2CacheSync(void)
#endif
{
#ifdef CONFIG_PL310_ERRATA_753970
	Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_DUMMY_CACHE_SYNC_OFFSET, 0x0U);
#else
	Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_CACHE_SYNC_OFFSET, 0x0U);
#endif
}

/****************************************************************************
*
* Enable the L2 cache.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void Xil_L2CacheEnable_lucia(void)
{
	register u32 L2CCReg;

	L2CCReg = Xil_In32(XPS_L2CC_BASEADDR + XPS_L2CC_CNTRL_OFFSET);

	/* only enable if L2CC is currently disabled */
	if ((L2CCReg & 0x01U) == 0U) {
		/* set up the way size and latencies */
		L2CCReg = Xil_In32(XPS_L2CC_BASEADDR +
				   XPS_L2CC_AUX_CNTRL_OFFSET);
		L2CCReg &= XPS_L2CC_AUX_REG_ZERO_MASK;
		L2CCReg |= 0x30060000U;
		Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_AUX_CNTRL_OFFSET,
			  L2CCReg);
		Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_TAG_RAM_CNTRL_OFFSET,
			  0x00000000);
		Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_DATA_RAM_CNTRL_OFFSET,
			  0x00000121);

		/* Clear the pending interrupts */
		L2CCReg = Xil_In32(XPS_L2CC_BASEADDR +
				   XPS_L2CC_ISR_OFFSET);
		Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_IAR_OFFSET, L2CCReg);

		Xil_L2CacheInvalidate();
		/* Enable the L2CC */
		L2CCReg = Xil_In32(XPS_L2CC_BASEADDR +
				   XPS_L2CC_CNTRL_OFFSET);
		Xil_Out32(XPS_L2CC_BASEADDR + XPS_L2CC_CNTRL_OFFSET,
			  (L2CCReg | (0x01U)));

        Xil_L2CacheSync();
        /* synchronize the processor */
	    dsb();

    }

}

