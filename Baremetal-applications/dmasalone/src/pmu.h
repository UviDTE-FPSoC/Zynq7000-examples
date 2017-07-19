/*
 * pmu.h
 *
 *  Created on: 28/07/2016
 *      Author: lucia
 */

#ifndef PMU_H_
#define PMU_H_


#ifdef __cplusplus
  extern "C" {
#endif


/* Includes ---------------------------------------------*/

/* Exported types ---------------------------------------*/

/* Exported constants -----------------------------------*/

/* Exported macros --------------------------------------*/

/* Exported functions -----------------------------------*/

void extern pmu_init(void);

void extern pmu_init_ns(int cpu_freq, int freq_div);

float extern pmu_getres_ns(void);

void extern pmu_counter_enable(void);

void extern pmu_counter_disable(void);

void  extern pmu_counter_reset(void);

int extern pmu_counter_read(unsigned int *counter_value);

int extern pmu_counter_read_ns(unsigned long long int *value_ns);

#ifdef __cplusplus
  }
#endif



#endif /* PMU_H_ */
