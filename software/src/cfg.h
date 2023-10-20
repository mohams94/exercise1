

#ifndef __CFG_H__
#define __CFG_H__

#include <assert.h>

//default to Nios2 as target
#if !defined(PC_TARGET) && !defined(NIOS2_TARGET)
	#define NIOS2_TARGET
#endif


//uncomment the following line to enable the software normalization function on the NIOS II
//#define USE_SOFTWARE_IMPLEMENTATION

#define MUL 0
#define DIV 1
#define CALCULATION_METHOD DIV

#if defined(NIOS2_TARGET)
	#include "system.h"
	#include "altera_avalon_timer_regs.h"
	#include "sys/alt_stdio.h"
	#include "sys/alt_irq.h"
	#include "v3norm.h"
	
	#define QUAUX(X) #X
	#define QU(X) QUAUX(X)
#endif


//Just to be on the safe side with the casts for scanf/printf
static_assert(sizeof(unsigned int) == sizeof(fix16_t), "unsigned int does not seem to be 32 bits");
static_assert(sizeof(uint32_t) == sizeof(fix16_t), "unsigned int does not seem to be 32 bits");


#endif


