#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <ctype.h>
#include <assert.h>
#include <string.h>
#include "fix16.h"

#include "cfg.h"

#define VEC3_BUFFER_SIZE 64


#if defined(PC_TARGET)
#include <linux/time.h>
uint64_t GetTickCountUs()
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (uint64_t)(ts.tv_nsec / 1000) + ((uint64_t)ts.tv_sec * 1000000ull);
}

uint64_t GetTickCountNs()
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (uint64_t)(ts.tv_nsec) + ((uint64_t)ts.tv_sec * 1000000000ull);
}
#endif



fix16_t value_buffer[3*VEC3_BUFFER_SIZE];
fix16_t value_buffer_2[3*VEC3_BUFFER_SIZE];

void run();
void check_speed();
void done(int e);

void read_values(fix16_t* dest, uint32_t count);
void print_values(fix16_t* values, uint32_t count);
void print_values_double(fix16_t* values, uint32_t count);

void process(fix16_t* values, uint32_t count);
void v3norm_sw(fix16_t* values, uint32_t count);

int main()
{
	//alt_irq_disable_all ();
	run();
	return 0;
}


void check_speed()
{
#if defined(NIOS2_TARGET)
	uint32_t run_times[16];
	alt_irq_context status;
	uint32_t time1, time2;
	IOWR_ALTERA_AVALON_TIMER_PERIODL(SYS_TIMER_BASE, 0xffff);
	IOWR_ALTERA_AVALON_TIMER_PERIODH(SYS_TIMER_BASE, 0xffff);  
	IOWR_ALTERA_AVALON_TIMER_CONTROL(SYS_TIMER_BASE, 0x6); //continous mode 
#elif defined(PC_TARGET)
	uint32_t run_times[16];
	uint64_t time1, time2;
#endif

	for (int j=0; j<16; j++){

		for(int i=0; i<3*VEC3_BUFFER_SIZE; i++) {
			value_buffer[i] = 0x10000;
		}
		
#if defined(NIOS2_TARGET)
		status = alt_irq_disable_all ();
		IOWR_ALTERA_AVALON_TIMER_SNAPL(SYS_TIMER_BASE,0); //freeze timestamp
		time1 = IORD_ALTERA_AVALON_TIMER_SNAPL(SYS_TIMER_BASE); //read lower 16 bit of time stamp
		time1 |= (IORD_ALTERA_AVALON_TIMER_SNAPH(SYS_TIMER_BASE) << 16); //load upper 16 bits
#elif defined(PC_TARGET)
		time1 = GetTickCountNs();
#endif
		process(value_buffer, VEC3_BUFFER_SIZE);
		
#if defined(NIOS2_TARGET)
		IOWR_ALTERA_AVALON_TIMER_SNAPL(SYS_TIMER_BASE,0);
		time2 = IORD_ALTERA_AVALON_TIMER_SNAPL(SYS_TIMER_BASE);
		time2 |= (IORD_ALTERA_AVALON_TIMER_SNAPH(SYS_TIMER_BASE) << 16);
		alt_irq_enable_all (status);
#elif defined(PC_TARGET)
		time2 = GetTickCountNs();
#endif
		unsigned int diff;

		if (time1 > time2) {
			diff = (unsigned int)(time1-time2);
		}else{
			diff = (unsigned int)(time2-time1);
		}
		//printf("time: %d\n", diff);
		run_times[j] = diff;
	}
	//calculate minimum of 16 runs
	uint32_t minimum_runtime = 0xffffffff;
	for (int j=0; j<16; j++){
		if (run_times[j] < minimum_runtime) {
			minimum_runtime = run_times[j];
		}
	}
	printf("%d\n", (unsigned int)minimum_runtime);
}

void run()
{
/*
		fix16_t x = ALT_CI_CI_DIV(0,6,3);

		alt_printf("A%x\n", ALT_CI_CI_DIV(1,0,0));

/*

		for (fix16_t i=1; i <= 50; i++) {
	
		fix16_t x = 0x00090000;
		fix16_t y = 0x00040000;
		fix16_t z = 0x00010000;
		

		IOWR(AVALON_MM_SQRT_BASE, 0, ALT_CI_CI_MUL(x, x) + ALT_CI_CI_MUL(y, y) + ALT_CI_CI_MUL(z, z));
		alt_printf("A%x\n", i);
		while(IORD(AVALON_MM_SQRT_BASE, 0));	// wait
		alt_printf("B%x\n", i);
		fix16_t len = IORD(AVALON_MM_SQRT_BASE, 1);
		alt_printf("C%x\n", i);


		fix16_t x_norm = ALT_CI_CI_DIV(0,x,len);	
		alt_printf("D%x\n", i);
		fix16_t y_norm = ALT_CI_CI_DIV(0,y,len);
		alt_printf("E%x\n", i);
		fix16_t z_norm = ALT_CI_CI_DIV(0,z,len);
		alt_printf("F%x\n", i);
								
		alt_printf("DIV_WRITE #### %x ####\n" , ALT_CI_CI_DIV(1,x_norm,len));
		alt_printf("G%x\n", i);
		alt_printf("DIV_WRITE #### %x ####\n" , ALT_CI_CI_DIV(1,y_norm,len));
		alt_printf("H%x\n", i);
		alt_printf("DIV_WRITE #### %x ####\n" , ALT_CI_CI_DIV(1,z_norm,len));
	}*/
	
	//alt_printf("DIV_WRITE #### %x ####\n" , ALT_CI_CI_DIV(0x0, 0x000a0000, 0x00050000));
	
	//alt_printf("DIV_READ #### %x ####\n" , ALT_CI_CI_DIV(0x1, 0, 0));
/*
	alt_printf(ALT_CI_CI_DIV_N_MASK);
	alt_printf("\n");
	alt_printf(ALT_CI_CI_DIV_N);
	alt_printf("\n");
	alt_printf(ALT_CI_CI_DIV_N_MASK & ALT_CI_CI_DIV_N);
	//alt_printf("MUL: #### %x ####\n" , ALT_CI_CI_MUL(0x00090000,0x00010000));
	
	
	IOWR(AVALON_MM_SQRT_BASE, 0, 0x00010000);
	while(IORD(AVALON_MM_SQRT_BASE, 0));
	//IORD(AVALON_MM_SQRT_BASE, 1);
	
	IOWR(AVALON_MM_SQRT_BASE, 0, 0x00090000);
	while(IORD(AVALON_MM_SQRT_BASE, 0));
	alt_printf("SQRT: #### %x ####\n", IORD(AVALON_MM_SQRT_BASE, 1));
	
	IOWR(AVALON_MM_SQRT_BASE, 0, 0x00040000);
	while(IORD(AVALON_MM_SQRT_BASE, 0));
	alt_printf("SQRT: #### %x ####\n", IORD(AVALON_MM_SQRT_BASE, 1));
	
	while(IORD(AVALON_MM_SQRT_BASE, 0));
	alt_printf("SQRT: #### %x ####\n", IORD(AVALON_MM_SQRT_BASE, 1));*/
	
	//alt_printf("1 #### %x ####\n" , ALT_CI_CI_DIV(0,0x00090000,0x00030000));
/*
	alt_printf("1 #### %x ####\n" , ALT_CI_CI_DIV(0,0xFFFFFFFF,0xFFFFFFFF));
	alt_printf("2 #### %x ####\n" , ALT_CI_CI_DIV(0,0x12345678,0x12345678));
	alt_printf("4 #### %x ####\n" , ALT_CI_CI_DIV(1,0,0));
	alt_printf("5 #### %x ####\n" , ALT_CI_CI_DIV(1,0,0));
	
	alt_printf("write number into sqrt module:");
	IOWR(AVALON_MM_SQRT_BASE, 0, 0x00000001);
	alt_printf(" done\n\n");
	alt_printf("wait for calculation:");
	while(IORD(AVALON_MM_SQRT_BASE, 0));
	alt_printf(" done\n\n");
	alt_printf("read result from sqrt module:");
	alt_printf("#### %x #### done.", IORD(AVALON_MM_SQRT_BASE, 1));*/
	alt_printf("1 #### %x ####\n" , ALT_CI_CI_DIV(0,0xFFFFFFFF,0xFFFFFFFF));
	alt_printf("1 #### %x ####\n" , ALT_CI_CI_DIV(0,0x12345678,0x12345678));
	alt_printf("#### %x #### done.", ALT_CI_CI_DIV(1,0,0));
	alt_printf("#### %x #### done.", ALT_CI_CI_DIV(1,0,0));
	
	alt_printf("1 #### %x ####\n" , ALT_CI_CI_DIV(0,0xFFFFFFFF,0xFFFFFFFF));
	alt_printf("2 #### %x ####\n" , ALT_CI_CI_DIV(0,0x12345678,0x12345678));
	alt_printf("4 #### %x ####\n" , ALT_CI_CI_DIV(1,0,0));
	alt_printf("5 #### %x ####\n" , ALT_CI_CI_DIV(1,0,0));
	
	char line_buffer[16];

	while(1){
		if ( fgets (line_buffer, 16, stdin) != NULL ){

			if (strncmp(line_buffer, "\n", 1) == 0) {
				continue;//ignore empty lines
			} else if (strncmp(line_buffer, "exit", 4) == 0) {
				done(0);
			} else if (strncmp(line_buffer, "process", 7) == 0){
				int value_count = 0;
				sscanf(&line_buffer[7],"%i\n", &value_count);
				read_values(value_buffer, value_count*3);
				process(value_buffer, value_count);
				print_values(value_buffer, value_count*3);
			} else if (strncmp(line_buffer, "check_speed", 11) == 0){
				check_speed();
			} else {
				printf("Input format error! [%s]",line_buffer);
				done(1);
			}
		} else {
			done(0);
		}
	}
}

void done(int e)
{
#ifdef NIOS2_TARGET
	if(e > 0) {
		printf("Some error occourd %i\n", e);
	}
	printf("%c",0x04); // force nios2-terminal to exit
#elif PC_TARGET
	exit(e);
#endif
}

void read_values(fix16_t* dest, uint32_t count)
{
	char line_buffer[32];
	for (int i=0; i<count; i++) {
		fgets(line_buffer, 32, stdin);
		sscanf(line_buffer, "%x", (unsigned int*)&dest[i]);
	}
}

void print_values(fix16_t* values, uint32_t count)
{
	for (int i=0; i<count; i++) {
		printf("0x%08x\n", (unsigned int)values[i]);
	}
}

void print_values_double(fix16_t* values, uint32_t count)
{
	for (int i=0; i<count; i++) {
		printf("%f\n", fix16_to_dbl(values[i]));
	}
}


void process(fix16_t* values, uint32_t count)
{
#if defined(NIOS2_TARGET) && !defined(USE_SOFTWARE_IMPLEMENTATION)
	v3norm(values, count);
#else
	v3norm_sw(values, count);
#endif
}


void v3norm_sw(fix16_t* values, uint32_t count)
{
	for (uint32_t i=0; i<count; i++) {
	
		fix16_t x = values[3*i];
		fix16_t y = values[3*i+1];
		fix16_t z = values[3*i+2];

		fix16_t len = fix16_sqrt(
			fix16_add(
				fix16_mul(x,x),
				fix16_add(
					fix16_mul(y,y),
					fix16_mul(z,z)
				)
			)
		);

		#ifndef CALCULATION_METHOD 
			#error "CALCULATION_METHOD must be set to either MUL (0) or DIV (1)"
		#endif

		#if CALCULATION_METHOD == DIV
		fix16_t x_norm = fix16_div(x,len);
		fix16_t y_norm = fix16_div(y,len);
		fix16_t z_norm = fix16_div(z,len);
		#elif CALCULATION_METHOD == MUL
		fix16_t len_inv = fix16_div(fix16_one,len);
		fix16_t x_norm = fix16_mul(x,len_inv);
		fix16_t y_norm = fix16_mul(y,len_inv);
		fix16_t z_norm = fix16_mul(z,len_inv);
		#endif
		
		values[3*i] = x_norm;
		values[3*i+1] = y_norm;
		values[3*i+2] = z_norm;
	}
}



