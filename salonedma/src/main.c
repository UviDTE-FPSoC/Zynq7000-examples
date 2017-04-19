/* main.c
 *
 *  Created on: 28/07/2016
 *      Author: lucia
 */


#include <stdio.h> //printf
#include <string.h> //to use memcpy
#include <stdlib.h> // to use malloc and free
#include <inttypes.h>
//#include "alt_dma_modified.h"
//#include "socal.h"
//#include "hps.h"
#include "hwlib.h"
//#include "platform.h"
#include "main_functions.h"
#include "pmu.h"

#include "xdmaps_hw.h"
#include "xdmaps_mod.h"
#include "xscugic.h"
#include "xilinxdma_sa.h"


/* enable semihosting with gcc by defining an __auto_semihosting symbol */
int __auto_semihosting;


#define REP_TESTS 100 //repetitions of every time measurement
#define CLK_REP_TESTS 1000

#define FORLOOP //Uncomment if you want to measure transfers using for loop (direct method)

//----------------------CACHE CONFIGURATION------------------------//
#define CACHE_CONFIG 8
/*Options for cache config (each config is added to the all previous ones):
0 no cache
(basic config and optimizations)
1 enable MMU
2 do 1 and initialize L2C
3 do 2 and enable SCU
4 do 3 and enable L1_I
5 do 4 and enable branch prediction
6 do 5 and enable L1_D
7 do 6 and enable L1 D side prefetch
8 do 7 and enable L2C
(special L2C-310 controller + Cortex A9 optimizations)
9 do 8 and enable L2 prefetch hint
10 do 9 and enable write full line zeros
11 do 10 and enable speculative linefills of L2 cache
12 do 11 and enable early BRESP
13 do 12 and store_buffer_limitation
*/

int main(void)
{

	#define ON_CHIP_MEMORY_BASE 0x00000000
	#define ON_CHIP_MEMORY_SPAN 0x2000 //size in bytes of memory
	#define ONCHIP_MEMORY_END ONCHIP_MEMORY2_0_END
	//define variable type depending on on-chip RAM data width
	#define UINT_SOC uint32_t
	//constants to write and read memory
	#define BYTES_DATA_BUS 4
	#define MEMORY_SIZE_IN_WORDS (ON_CHIP_MEMORY_SPAN/BYTES_DATA_BUS) //number of 32bit words
	//macros to define hardware directions
	#define BRIDGE_BASE 0x40000000 //default start for HPS-FPGA High


	printf("-----MEASURING FPGA-HPS BRIDGES SPEED IN BAREMETAL----\n\r\r");

	//printf("Size of uint32_soc is %d\n\r", sizeof(uint32_soc));
	//printf("Size of uint64_soc is %d\n\r", sizeof(uint64_soc));
	//printf("Size of uint128_t is %d\n\r", sizeof(uint128_soc));

	printf("Each measurement is repeated %d times\n\r", REP_TESTS);

	//------------------------VARIABLES INSTANTIATION-----------------------//
	//-------------Common variables------------//
	ALT_STATUS_CODE status = ALT_E_SUCCESS;

	int i, j, l; //vars for loops

	//cache configuration
	int cache_config = CACHE_CONFIG;

/*
	//DMA ones
	ALT_DMA_CHANNEL_t Dma_Channel;
	ALT_DMA_PROGRAM_t program;
	ALT_DMA_CHANNEL_STATE_t channel_state;
	ALT_DMA_CHANNEL_FAULT_t fault;
	char *rd_dst, *rd_src, *wr_dst, *wr_src; //source and destiny pointers for DMA in read and write from/to FPGA operations
	ALT_DMA_PROGRAM_t *programs_wr[8];
	ALT_DMA_PROGRAM_t *programs_rd[8];
	for (j=0; j<8; j++)
	{
		programs_wr[j]=(ALT_DMA_PROGRAM_t*) malloc(sizeof(ALT_DMA_PROGRAM_t));
		programs_rd[j]=(ALT_DMA_PROGRAM_t*) malloc(sizeof(ALT_DMA_PROGRAM_t));
	}
*/
	//DMA ones
	char* wr_dst;
	char* wr_src;
	int check;
	int Status;
	XDmaPs_Cmd *DmaCmd_wr[256];
	for (j=0; j<256;j++){
		DmaCmd_wr[j]=(XDmaPs_Cmd*) malloc(sizeof(XDmaPs_Cmd));
	}

	wr_dst = (char*) 0x40000000;
//	wr_src = (char*)((void*)(data)+0x80000000); //+0x80000000 to access through ACP

	XDmaPs DmaInstance;
	XScuGic GicInstance;
	XDmaPs_Cmd DmaCmd;
	u32 DmaProg;
	u32 BAdress;
	int Checked[XDMAPS_CHANNELS_PER_DEV];
	unsigned int Channel;

	//-------------Memory pointers------------//
	//FPGA On-Chip RAM
	void* FPGA_on_chip_RAM_addr = (void*)(BRIDGE_BASE + ON_CHIP_MEMORY_BASE); //address of FPGA OCR
	UINT_SOC* fpgaocr_ptr;//FPGA on chip RAM pointer

	//----Save intermediate results in speed tests-------//
	unsigned long long int total_clk, min_clk, max_clk, variance_clk, clk_read_average;

	unsigned long long int total_mcp_rd, min_mcp_rd, max_mcp_rd, variance_mcp_rd;
	unsigned long long int total_mcp_wr, min_mcp_wr, max_mcp_wr, variance_mcp_wr;

	unsigned long long int total_dma_rd, min_dma_rd, max_dma_rd, variance_dma_rd;
	unsigned long long int total_dma_wr, min_dma_wr, max_dma_wr, variance_dma_wr;

	//-----------some variables to define speed tests-------//
	//define data sizes
	int number_of_data_sizes = 21; //size of data_size[]
	int data_size [] =
	{2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
	2048, 4096, 8192, 16384, 32768,
	65536, 131072, 262144, 524288, 1048576,
	2097152}; //data size in bytes

	//-----------auxiliar variables to perform speed tests-------//
	char* data;
	int data_in_one_operation;//data to write or read from memory (bytes)
	int operation_loops; //number of loops to read/write all data from/to memory


	//Variables if For Loop Defined
	#ifdef FORLOOP
	int k;
	unsigned long long int total_dir_rd, min_dir_rd, max_dir_rd, variance_dir_rd;
	unsigned long long int total_dir_wr, min_dir_wr, max_dir_wr, variance_dir_wr;
	UINT_SOC* datai; //pointer to data
	int data_in_one_operation_w;//data to write or read from memory (words)
	int operation_w_loops; //number of loops to read/write all data from/to memory
	#endif

	//-------------CHECKING FPGA 256kB ON-CHIP RAM-------------//

	//Check the memory
	fpgaocr_ptr = (UINT_SOC *)FPGA_on_chip_RAM_addr;
	for (i=4; i<(MEMORY_SIZE_IN_WORDS); i++)
	{
		*fpgaocr_ptr = i;
		if (*fpgaocr_ptr != i){
			status = ALT_E_ERROR;
			printf("i during error %d\n\r", i);
		}
		fpgaocr_ptr++;
	}
	if (status == ALT_E_SUCCESS) printf("Check FPGA On-Chip RAM OK\n\r");
	else
	{
		printf ("Error when checking FPGA On-Chip RAM\n\r");
		return 1;
	}
	//Reset all memory
	fpgaocr_ptr = (UINT_SOC *)FPGA_on_chip_RAM_addr;
	for (i=0; i<MEMORY_SIZE_IN_WORDS; i++)
	{
		*fpgaocr_ptr = 0;
		if (*fpgaocr_ptr != 0) status = ALT_E_ERROR;;
		fpgaocr_ptr++;
	}
	if (status == ALT_E_SUCCESS) printf("Reset FPGA On-Chip RAM OK\n\r");
	else
	{
		printf ("Error when resetting FPGA On-Chip RAM \n\r");
		return 1;
	}


	//----------CONFIGURING CACHE-----------//
	cache_configuration(cache_config);
/*
	//-----------CONFIGURING ACP------------//
	status = acp_configuration();
	if(status == ALT_E_SUCCESS) printf("ACP ID Mapper configuration was succesful\n\r");
	else
	{
		printf("ACP ID Mapper configuration was not succesful\n\r");
		return ALT_E_ERROR;
	}
*/

	//---------------------------------------------TESTS USING PMU---------------------------------------//
	printf("\n\r------------STARTING TIME MEASUREMENTS------------\n\r");

	unsigned long long pmu_counter_ns;
	int overflow = 0;

	//-----------INITIALIZATION OF PMU AS TIMER------------//
	pmu_init_ns(667, 1); //Initialize PMU cycle counter, 667MHz source, frequency divider 1
	pmu_counter_enable();//Enable cycle counter inside PMU (it starts counting)
	float pmu_res = pmu_getres_ns();
	printf("PMU is used like timer with the following characteristics\n\r");
	printf("PMU cycle counter resolution is f ns\n\r" );
//	printf("PMU cycle counter resolution is %f ns\n\r", pmu_res );
	printf("Measuring PMU counter overhead...\n\r");
	reset_cumulative(&total_clk, &min_clk, &max_clk, &variance_clk);
	for(i = 0; i<CLK_REP_TESTS+2; i++)
	{
		pmu_counter_reset();
		overflow = pmu_counter_read_ns(&pmu_counter_ns);
		//printf("PMU counter (ns): %lld \n\r", pmu_counter_ns);
		if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}
		if (i>=2) update_cumulative(&total_clk, &min_clk, &max_clk, &variance_clk, 0, pmu_counter_ns, 0);
		//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)
	}
	printf("PMU Cycle Timer Statistics for %d consecutive reads\n\r", CLK_REP_TESTS);
	printf("Average, Minimum, Maximum, Variance\n\r");
	printf("%lld,%lld,%lld,%lld\n\r", clk_read_average = total_clk/CLK_REP_TESTS, min_clk, max_clk, variance (variance_clk , total_clk, CLK_REP_TESTS));

/*

	//-----------MOVING DATA WITH PROCESSOR------------//
	printf("\n\r--MOVING DATA WITH THE PROCESSOR--\n\r");
	//----------Do the speed test (using memcpy)--------------//
	printf("\n\rStart memcpy test\n\r");

	printf("Data Size,Average MCP_WR,Minimum MCP_WR,Maximum MCP_WR,Variance MCP_WR,Average MCP_RD,Minimum MCP_RD,Maximum MCP_RD,Variance MCP_RD\n\r");

	for(i=0; i<number_of_data_sizes; i++)//for each data size
	{
		reset_cumulative( &total_mcp_wr, &min_mcp_wr, &max_mcp_wr, &variance_mcp_wr);
		reset_cumulative( &total_mcp_rd, &min_mcp_rd, &max_mcp_rd, &variance_mcp_rd);

		for(l = 0; l<REP_TESTS+2; l++)
		{
			//reserve the exact memory of the data size
			data = (char*) malloc(data_size[i]);
			if (data == 0)
			{
				printf("ERROR when calling malloc: Out of memory2\n\r");
				return 1;
			}

			//save some content in data (for example: i)
			for (j=0; j<data_size[i]; j++) data[j] = i;

			//if data is bigger than on-chip size in bytes
			if (data_size[i]>ON_CHIP_MEMORY_SPAN)
			{
				data_in_one_operation = ON_CHIP_MEMORY_SPAN;
				operation_loops = data_size[i]/ON_CHIP_MEMORY_SPAN;
			}
			else
			{
				data_in_one_operation = data_size[i];
				operation_loops = 1;
			}

			//WRITE DATA TO ON-CHIP RAM

			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
				memcpy((void*) FPGA_on_chip_RAM_addr, (void *) (&(data[j*ON_CHIP_MEMORY_SPAN])), data_in_one_operation);

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}
			//printf("PMU counter (ns): %lld \n\r", pmu_counter_ns);

			if (l>=2) update_cumulative(&total_mcp_wr, &min_mcp_wr, &max_mcp_wr, &variance_mcp_wr, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//printf("%d: %lld, %lld, %lld, %lld, %lld\n\r",l, pmu_counter_ns-clk_read_average, total_mcp_wr, min_mcp_wr, max_mcp_wr, variance_mcp_wr);


			//READ DATA FROM ON-CHIP RAM

			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
				memcpy((void *) (&(data[j*ON_CHIP_MEMORY_SPAN])), (void*) FPGA_on_chip_RAM_addr, data_in_one_operation);

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}

			if (l>=2) update_cumulative(&total_mcp_rd, &min_mcp_rd, &max_mcp_rd, &variance_mcp_rd, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			for (j=0; j<data_size[i]; j++)
			{
				if (data[j] != i) status = ALT_E_ERROR;
			}
			if (status != ALT_E_SUCCESS)
			{
				printf ("Error when checking On-Chip RAM with data size %dB\n\r", data_size[i]);
				return 1;
			}
	//			else
	//				printf("Check On-Chip RAM with data size %dB was OK\n\r", data_size[i]);


			//free dynamic memory
			free(data);

		}

		printf("%d, %lld, %lld, %lld, %lld, %lld, %lld, %lld, %lld\n\r", data_size[i], total_mcp_wr/REP_TESTS, min_mcp_wr, max_mcp_wr, variance(variance_mcp_wr, total_mcp_wr, REP_TESTS), total_mcp_rd/REP_TESTS, min_mcp_rd, max_mcp_rd,  variance(variance_mcp_rd, total_mcp_rd, REP_TESTS) );
	}

	//print or save in file timing measurements

#ifdef FORLOOP
	//----------Do the speed test (using for loop)--------------//
	printf("\n\rStart for loop test\n\r");
	printf("Data Size,Average DIR_WR,Minimum DIR_WR,Maximum DIR_WR,Variance DIR_WR,Average DIR_RD,Minimum DIR_RD,Maximum DIR_RD,Variance DIR_RD\n\r");

	for(i=0; i<number_of_data_sizes; i++)//for each data size
	{
		reset_cumulative( &total_dir_wr, &min_dir_wr, &max_dir_wr, &variance_dir_wr);
		reset_cumulative( &total_dir_rd, &min_dir_rd, &max_dir_rd, &variance_dir_rd);

		for(l = 0; l<REP_TESTS; l++)
		{
			//reserve the exact memory of the data size (except when data is smaller than data bus size)
			if (data_size[i]<BYTES_DATA_BUS) datai = (UINT_SOC*) malloc(BYTES_DATA_BUS);
			else datai = (UINT_SOC*) malloc(data_size[i]);
			if (datai == 0)
			{
				printf("ERROR when calling malloc: Out of memory\n\r");
				return 1;
			}

			//save some content in data (for example: i)
			if (data_size[i]<BYTES_DATA_BUS) datai[0] = i;
			else for (j=0; j<(data_size[i]/BYTES_DATA_BUS); j++) datai[j] = i;

			//if data is bigger than on-chip size in bytes
			if (data_size[i]>ON_CHIP_MEMORY_SPAN)
			{
				data_in_one_operation_w = MEMORY_SIZE_IN_WORDS;
				operation_w_loops = (data_size[i]/BYTES_DATA_BUS)/MEMORY_SIZE_IN_WORDS;
			}
			else
			{
				if (data_size[i]<BYTES_DATA_BUS) //if data is smaller than bus width
				{
					data_in_one_operation_w = 1;
					operation_w_loops = 1;
				}
				else //data size is between data bus size and memory size
				{
					data_in_one_operation_w = data_size[i]/BYTES_DATA_BUS;
					operation_w_loops = 1;
				}
			}

			//WRITE DATA TO ON-CHIP RAM

			//read a value from clock to eliminate "first-read-jitter"
			pmu_counter_reset();

			int offset;
			for (j=0; j<operation_w_loops; j++)
			{
				offset = j*MEMORY_SIZE_IN_WORDS;
				for(k=0; k<data_in_one_operation_w; k++)
					fpgaocr_ptr[k] = datai[offset+k];
			}

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}

			update_cumulative(&total_dir_wr, &min_dir_wr, &max_dir_wr, &variance_dir_wr, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//READ DATA FROM ON-CHIP RAM

			pmu_counter_reset();

			for (j=0; j<operation_w_loops; j++)
			{
				offset = j*MEMORY_SIZE_IN_WORDS;
				for(k=0; k<data_in_one_operation_w; k++)
					datai[offset+k] = fpgaocr_ptr[k];
			}

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}

			update_cumulative(&total_dir_rd, &min_dir_rd, &max_dir_rd, &variance_dir_rd, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			for (j=0; j<data_size[i]/BYTES_DATA_BUS; j++)
			{
				if (datai[j] != i) status = ALT_E_ERROR;
			}
			if (status != ALT_E_SUCCESS)
			{
					printf ("Error when checking On-Chip RAM with data size %dB\n\r", data_size[i]);
					return 1;

			}
			//else printf("Check On-Chip RAM with data size %dB was OK\n\r", data_size[i]);

			//free memory used
			free(datai);
		}

		printf("%d, %lld, %lld, %lld, %lld, %lld, %lld, %lld, %lld\n\r", data_size[i], total_dir_wr/REP_TESTS, min_dir_wr, max_dir_wr, variance(variance_dir_wr, total_dir_wr, REP_TESTS), total_dir_rd/REP_TESTS, min_dir_rd, max_dir_rd,  variance(variance_dir_rd, total_dir_rd, REP_TESTS) );
	}
#endif
*/

	//-----------MOVING DATA WITH DMAC------------//
	printf("\n\r--MOVING DATA WITH THE DMAC--\n\r");
/*
	// Initialize DMA Controller
    printf("INFO: Initializing DMA controller.\n\r");
    status = system_init();
    if (status != ALT_E_SUCCESS)
	{
		printf("ERROR when initializing DMA Controller. Return\n\r");
		return 1;
	}
*/
	Status =  XDmaSA_Init(&GicInstance, &DmaInstance, DMA_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		xil_printf("Error: XDMaPs_Example_Init failed\r\n");
		return XST_FAILURE;
	}


	printf("\n\r--Starting DMAC tests (DMAC program preparation time included)--\n\r");
	//Moving data with DMAC (DMAC program preparation is measured)
	printf("Data Size,Average DMA_WR,Minimum DMA_WR,Maximum DMA_WR,Variance DMA_WR,Average DMA_RD,Minimum DMA_RD,Maximum DMA_RD,Variance DMA_RD\n\r");
    for(i=0; i<number_of_data_sizes; i++)//for each data size
	{
		reset_cumulative( &total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr);
		reset_cumulative( &total_dma_rd, &min_dma_rd, &max_dma_rd, &variance_dma_rd);


		//if data is bigger than on-chip size in bytes
		if (data_size[i]>ON_CHIP_MEMORY_SPAN)
		{
			data_in_one_operation = ON_CHIP_MEMORY_SPAN;
			operation_loops = data_size[i]/ON_CHIP_MEMORY_SPAN;
		}
		else
		{
			data_in_one_operation = data_size[i];
			operation_loops = 1;
		}


		//reserve the exact memory of the data size
		data = (char*) malloc(data_size[i]);
		if (data == 0)
		{
			printf("ERROR when calling malloc: Out of memory\n\r");
			return 1;
		}

		//		wr_dst = (char*) 0x40000000;
		wr_src = data; //+0x80000000 to access through ACP

		//save some content in data (for example: i)
		for (j=0; j<data_size[i]; j++) data[j] = i;

		for (j=0; j<operation_loops; j++)
		{
			//write programs
			XDmaSA_Program((void*)(&(wr_src[j*ON_CHIP_MEMORY_SPAN])), (void*)wr_dst, (size_t) data_in_one_operation, DmaCmd_wr[j]);
		}


		for(l = 0; l<REP_TESTS+2; l++)
		{
			Channel=0;
			/* Set the Done interrupt handler */
			XDmaPs_SetDoneHandler(&DmaInstance, Channel, DmaDoneHandler, (void *)Checked);

			pmu_counter_reset();
			for (j=0; j<operation_loops; j++)
			{
				Checked[Channel] = 0;

				Status = XDmaPs_Start_Program(&DmaInstance, Channel, DmaCmd_wr[j], 0);
				if (Status != XST_SUCCESS) {
					printf("XDmaPs_Start_Transfer_Program error\n\r");
					return XST_FAILURE;
				}

			/* Incluir bucle para saturar memoria dinamica */

//				Status = XDmaPs_Start_Transfer(&DmaInstance, Channel, DmaCmd_wr[j], 0, DmaProg);
//				if (Status != XST_SUCCESS)
//					printf("XDmaPs_Start_Transfer error\n\r");

/*				if (DmaProg){
					Status = XDmaPs_Exec_DMAGO(DmaInstance.Config.BaseAddress, Channel, (u32)DmaProg);
					if (Status != XST_SUCCESS)
						printf("XDmaPs_Exec_DMAGO error\n\r");*/

					while (Checked[Channel] == 0){ //wait DMAC to finish
//						printf("Waiting DMA...\n\r");
					}
/*				}
				else {
					DmaInstance.Chans[Channel].DmaCmdToHw = NULL;
					Status = XST_FAILURE;
					xil_printf("Error: Aqui2\r\n");
				}*/


			}
			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}
			//printf("PMU counter (ns): %lld \n\r", pmu_counter_ns);

			if (l>=2) update_cumulative(&total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			// Compare results
//			printf("INFO: Comparing source and destination buffers.\n\r");
			if(0  != memcmp(&(data[0]), (void*) wr_dst, data_in_one_operation))
			{
				printf("DMA source and destiny have different data on WR!! Program ended\n\r");return 1;
			}
//			printf("Check with data size %dB was OK\n\r", data_size[i]);
		}
		printf("Check with data size %dB was OK aqui\n\r", data_size[i]);
		printf("%d, %lld, %lld, %lld, %lld, %lld, %lld, %lld, %lld\n\r", data_size[i], total_dma_wr/REP_TESTS, min_dma_wr, max_dma_wr, variance(variance_dma_wr, total_dma_wr, REP_TESTS), total_dma_rd/REP_TESTS, min_dma_rd, max_dma_rd,  variance(variance_dma_rd, total_dma_rd, REP_TESTS) );

		//free dynamic memory
		free(data);
	}


/*	// Allocate DMA Channel
    printf("INFO: Allocating DMA channel.\n\r");
    status = alt_dma_channel_alloc_any(&Dma_Channel);
    if (status != ALT_E_SUCCESS)
	{
		printf("ERROR allocating DMA channel. Return\n\r");
		return 1;
	}

	printf("\n\r--Starting DMAC tests (DMAC program preparation time included)--\n\r");
	//Moving data with DMAC (DMAC program preparation is measured)
	printf("Data Size,Average DMA_WR,Minimum DMA_WR,Maximum DMA_WR,Variance DMA_WR,Average DMA_RD,Minimum DMA_RD,Maximum DMA_RD,Variance DMA_RD\n\r");
    for(i=0; i<number_of_data_sizes; i++)//for each data size
	{
		reset_cumulative( &total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr);
		reset_cumulative( &total_dma_rd, &min_dma_rd, &max_dma_rd, &variance_dma_rd);


		//if data is bigger than on-chip size in bytes
		if (data_size[i]>ON_CHIP_MEMORY_SPAN)
		{
			data_in_one_operation = ON_CHIP_MEMORY_SPAN;
			operation_loops = data_size[i]/ON_CHIP_MEMORY_SPAN;
		}
		else
		{
			data_in_one_operation = data_size[i];
			operation_loops = 1;
		}

		for(l = 0; l<REP_TESTS+2; l++)
		{
			//reserve the exact memory of the data size
			data = (char*) malloc(data_size[i]);
			if (data == 0)
			{
				printf("ERROR when calling malloc: Out of memory\n\r");
				return 1;
			}

			if (cache_config >= 6) //if data cache is on access through ACP to coherent data in cache
			{
				wr_dst = (char*) FPGA_on_chip_RAM_addr;
				wr_src = (char*)((void*)(data)+0x80000000); //+0x80000000 to access through ACP
				rd_dst = (char*)((void*)(data)+0x80000000);
				rd_src = (char*) FPGA_on_chip_RAM_addr;
			}
			else//if data cache is off it does not make sense to access through ACP (it will be slower than direct access to sdram controller)
			{
				wr_dst = (char*) FPGA_on_chip_RAM_addr;
				wr_src = data;
				rd_dst = data;
				rd_src = (char*) FPGA_on_chip_RAM_addr;
			}

			//save some content in data (for example: i)
			for (j=0; j<data_size[i]; j++) data[j] = i;

			//--WRITE DATA TO FPGA ON-CHIP RAM
			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
			{
				status = alt_dma_memory_to_memory(Dma_Channel, &program, wr_dst,
					&(wr_src[j*ON_CHIP_MEMORY_SPAN]), data_in_one_operation, false, (ALT_DMA_EVENT_t)0);
				//status = alt_dma_memory_to_memory(Dma_Channel, &program, dst, src, size, false, (ALT_DMA_EVENT_t)0);

				// Wait for transfer to complete
				if (status == ALT_E_SUCCESS)
				{
					//printf("INFO: Waiting for DMA transfer to complete.\n\r");
					channel_state = ALT_DMA_CHANNEL_STATE_EXECUTING;
					while((status == ALT_E_SUCCESS) && (channel_state != ALT_DMA_CHANNEL_STATE_STOPPED))
					{
						status = alt_dma_channel_state_get(Dma_Channel, &channel_state);
						if(channel_state == ALT_DMA_CHANNEL_STATE_FAULTING)
						{
							alt_dma_channel_fault_status_get(Dma_Channel, &fault);
							printf("ERROR: DMA Channel Fault: %d. Return\n\r", (int)fault);
							return 1;
						}
					}
				}
			}
			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}
			//printf("PMU counter (ns): %lld \n\r", pmu_counter_ns);

			if (l>=2) update_cumulative(&total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			// Compare results
			//printf("INFO: Comparing source and destination buffers.\n\r");
			if(0  != memcmp(&(data[0]), FPGA_on_chip_RAM_addr, data_in_one_operation))
			{
				printf("DMA source and destiny have different data on WR!! Program ended\n\r");return 1;
			}

			//printf("%d: %lld, %lld, %lld, %lld, %lld\n\r",l, pmu_counter_ns-clk_read_average, total_dma_wr, min_dma_wr, max_dma_wr, variance_dma_wr);


			//--READ DATA FROM FPGA ON-CHIP RAM
			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
			{
				status = alt_dma_memory_to_memory(Dma_Channel, &program, &(rd_dst[j*ON_CHIP_MEMORY_SPAN]),
					rd_src, data_in_one_operation, false, (ALT_DMA_EVENT_t)0);
				//status = alt_dma_memory_to_memory(Dma_Channel, &program, dst, src, size, false, (ALT_DMA_EVENT_t)0);

				// Wait for transfer to complete
				if (status == ALT_E_SUCCESS)
				{
					//printf("INFO: Waiting for DMA transfer to complete.\n\r");
					channel_state = ALT_DMA_CHANNEL_STATE_EXECUTING;
					while((status == ALT_E_SUCCESS) && (channel_state != ALT_DMA_CHANNEL_STATE_STOPPED))
					{
						status = alt_dma_channel_state_get(Dma_Channel, &channel_state);
						if(channel_state == ALT_DMA_CHANNEL_STATE_FAULTING)
						{
							alt_dma_channel_fault_status_get(Dma_Channel, &fault);
							printf("ERROR: DMA CHannel Fault: %d. Return\n\r", (int)fault);
							return 1;
						}
					}
				}
			}

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}

			if (l>=2) update_cumulative(&total_dma_rd, &min_dma_rd, &max_dma_rd, &variance_dma_rd, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			// Compare results
			//printf("INFO: Comparing source and destination buffers.\n\r");
			if(0  != memcmp(&(data[0]), FPGA_on_chip_RAM_addr, data_in_one_operation))
			{
				printf("DMA source and destiny have different data on RD!! Program ended\n\r");return 1;
			}

			//free dynamic memory
			free(data);
		}

		printf("%d, %lld, %lld, %lld, %lld, %lld, %lld, %lld, %lld\n\r", data_size[i], total_dma_wr/REP_TESTS, min_dma_wr, max_dma_wr, variance(variance_dma_wr, total_dma_wr, REP_TESTS), total_dma_rd/REP_TESTS, min_dma_rd, max_dma_rd,  variance(variance_dma_rd, total_dma_rd, REP_TESTS) );
	}


	printf("\n\r--Starting DMAC tests (DMAC program preparation time NOT included)--\n\r");
	//Moving data with DMAC (DMAC program preparation is measured)
	printf("Data Size,Average DMA_WR,Minimum DMA_WR,Maximum DMA_WR,Variance DMA_WR,Average DMA_RD,Minimum DMA_RD,Maximum DMA_RD,Variance DMA_RD\n\r");
    for(i=0; i<number_of_data_sizes; i++)//for each data size
	{
		reset_cumulative( &total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr);
		reset_cumulative( &total_dma_rd, &min_dma_rd, &max_dma_rd, &variance_dma_rd);

		//reserve the exact memory of the data size
		data = (char*) malloc(data_size[i]);
		if (data == 0)
		{
			printf("ERROR when calling malloc: Out of memory\n\r");
			return 1;
		}

		if (cache_config >= 6) //if data cache is on access through ACP to coherent data in cache
		{
			wr_dst = (char*) FPGA_on_chip_RAM_addr;
			wr_src = (char*)((void*)(data)+0x80000000); //+0x80000000 to access through ACP
			rd_dst = (char*)((void*)(data)+0x80000000);
			rd_src = (char*) FPGA_on_chip_RAM_addr;
		}
		else//if data cache is off it does not make sense to access through ACP (it will be slower than direct access to sdram controller)
		{
			wr_dst = (char*) FPGA_on_chip_RAM_addr;
			wr_src = data;
			rd_dst = data;
			rd_src = (char*) FPGA_on_chip_RAM_addr;
		}

		//if data is bigger than on-chip size in bytes
		if (data_size[i]>ON_CHIP_MEMORY_SPAN)
		{
			data_in_one_operation = ON_CHIP_MEMORY_SPAN;
			operation_loops = data_size[i]/ON_CHIP_MEMORY_SPAN;
		}
		else
		{
			data_in_one_operation = data_size[i];
			operation_loops = 1;
		}

		//reserve memory for the DMAC programs
		//ALT_DMA_PROGRAM_t *programs_wr = (ALT_DMA_PROGRAM_t*) malloc(operation_loops*sizeof(ALT_DMA_PROGRAM_t)); //one program per loop
		//ALT_DMA_PROGRAM_t *programs_rd = (ALT_DMA_PROGRAM_t*) malloc(operation_loops*sizeof(ALT_DMA_PROGRAM_t)); //one program per loop

		for (j=0; j<operation_loops; j++)
		{
			//write programs
			alt_dma_memory_to_memory_only_prepare_program(Dma_Channel, programs_wr[j], wr_dst,
					&(wr_src[j*ON_CHIP_MEMORY_SPAN]), data_in_one_operation, false, (ALT_DMA_EVENT_t)0);
			//read programs
			alt_dma_memory_to_memory_only_prepare_program(Dma_Channel, programs_rd[j], &(rd_dst[j*ON_CHIP_MEMORY_SPAN]),
					rd_src, data_in_one_operation, false, (ALT_DMA_EVENT_t)0);
		}

		for(l = 0; l<REP_TESTS+2; l++)
		{

			//save some content in data (for example: i)
			for (j=0; j<data_size[i]; j++) data[j] = i;

			//--WRITE DATA TO FPGA ON-CHIP RAM
			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
			{
				status = alt_dma_channel_exec(Dma_Channel, programs_wr[j]);

				// Wait for transfer to complete
				if (status == ALT_E_SUCCESS)
				{
					//printf("INFO: Waiting for DMA transfer to complete.\n\r");
					channel_state = ALT_DMA_CHANNEL_STATE_EXECUTING;
					while((status == ALT_E_SUCCESS) && (channel_state != ALT_DMA_CHANNEL_STATE_STOPPED))
					{
						status = alt_dma_channel_state_get(Dma_Channel, &channel_state);
						if(channel_state == ALT_DMA_CHANNEL_STATE_FAULTING)
						{
							alt_dma_channel_fault_status_get(Dma_Channel, &fault);
							printf("ERROR: DMA Channel Fault: %d. Return\n\r", (int)fault);
							return 1;
						}
					}
				}
			}

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}
			//printf("PMU counter (ns): %lld \n\r", pmu_counter_ns);

			if (l>=2) update_cumulative(&total_dma_wr, &min_dma_wr, &max_dma_wr, &variance_dma_wr, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			// Compare results
			//printf("INFO: Comparing source and destination buffers.\n\r");
			if(0  != memcmp(&(data[0]), FPGA_on_chip_RAM_addr, data_in_one_operation))
			{
				printf("DMA source and destiny have different data on WR!! Program ended\n\r");return 1;
			}

			//printf("%d: %lld, %lld, %lld, %lld, %lld\n\r",l, pmu_counter_ns-clk_read_average, total_dma_wr, min_dma_wr, max_dma_wr, variance_dma_wr);


			//--READ DATA FROM FPGA ON-CHIP RAM
			pmu_counter_reset();

			for (j=0; j<operation_loops; j++)
			{
				status = alt_dma_channel_exec(Dma_Channel, programs_rd[j]);

				// Wait for transfer to complete
				if (status == ALT_E_SUCCESS)
				{
					//printf("INFO: Waiting for DMA transfer to complete.\n\r");
					channel_state = ALT_DMA_CHANNEL_STATE_EXECUTING;
					while((status == ALT_E_SUCCESS) && (channel_state != ALT_DMA_CHANNEL_STATE_STOPPED))
					{
						status = alt_dma_channel_state_get(Dma_Channel, &channel_state);
						if(channel_state == ALT_DMA_CHANNEL_STATE_FAULTING)
						{
							alt_dma_channel_fault_status_get(Dma_Channel, &fault);
							printf("ERROR: DMA CHannel Fault: %d. Return\n\r", (int)fault);
							return 1;
						}
					}
				}
			}

			overflow = pmu_counter_read_ns(&pmu_counter_ns);
			if (overflow == 1){printf("Cycle counter overflow!! Program ended\n\r");return 1;}

			if (l>=2) update_cumulative(&total_dma_rd, &min_dma_rd, &max_dma_rd, &variance_dma_rd, 0, pmu_counter_ns, clk_read_average);
			//(We erase two first measurements because they are different from the others. Reason:Branch prediction misses when entering for loop)

			//check the content of the data just read
			// Compare results
			//printf("INFO: Comparing source and destination buffers.\n\r");
			if(0  != memcmp(&(data[0]), FPGA_on_chip_RAM_addr, data_in_one_operation))
			{
				printf("DMA source and destiny have different data on RD!! Program ended\n\r");return 1;
			}
		}

		printf("%d, %lld, %lld, %lld, %lld, %lld, %lld, %lld, %lld\n\r", data_size[i], total_dma_wr/REP_TESTS, min_dma_wr, max_dma_wr, variance(variance_dma_wr, total_dma_wr, REP_TESTS), total_dma_rd/REP_TESTS, min_dma_rd, max_dma_rd,  variance(variance_dma_rd, total_dma_rd, REP_TESTS) );

		//free dynamic memory
		free(data);
	}
*/
	printf("\n\rData transfer measurements finished!!!!\n\r");

    return 0;
}
