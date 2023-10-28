#include "v3norm.h"

#ifdef NIOS2_TARGET

void v3norm(fix16_t* values, uint32_t count)
{
//your code goes here
    /*fix16_t result = 0;
    
    for (uint32_t i = 0; i < count; i++) {
        
        
        //fix16_t result = ALT_CI_CI_MUL(values[3 * i], values[3 * i]) + ALT_CI_CI_MUL(values[3 * i + 1], values[3 * i + 1]) + ALT_CI_CI_MUL(values[3 * i + 2], values[3 * i + 2]);
        
        //x2 = ALT_CI_CI_DIV(0, 1, x2 + y2 + z2)
        
        //values[3 * i] = x;
        //values[3 * i + 1] = y;
        //values[3 * i + 2] = z;
    }
    
    for(int i = 0; i < 2 * count; i++){
    	if (IORD(AVALON_MM_SQRT_BASE, 0)){
		x2 = IORD(AVALON_MM_SQRT_BASE, 1);
	}
	ALT_CI_CI_DIV(0, 1, x2 + y2 + z2);
	values[i] = 0;//ALT_CI_CI_DIV(1, 0, values[i]);
	}*/
	
    // ########################### rewritten main() function ##########################
    
	for (fix16_t i=0; i < count; i++) {
	
		fix16_t x = values[3*i];
		fix16_t y = values[3*i+1];
		fix16_t z = values[3*i+2];
		

		IOWR(AVALON_MM_SQRT_BASE, 0, ALT_CI_CI_MUL(values[3*i], values[3*i]) + ALT_CI_CI_MUL(values[3*i+1], values[3*i+1]) + ALT_CI_CI_MUL(values[3*i+2], values[3*i+2]));
		
		while(IORD(AVALON_MM_SQRT_BASE, 0));	// wait
		
		fix16_t len = IORD(AVALON_MM_SQRT_BASE, 1);
		


		fix16_t x_norm = ALT_CI_CI_DIV(0,x,len);	
		fix16_t y_norm = ALT_CI_CI_DIV(0,y,len);
		fix16_t z_norm = ALT_CI_CI_DIV(0,z,len);
								
		values[3*i] = ALT_CI_CI_DIV(1,x_norm,len);
		values[3*i+1] = ALT_CI_CI_DIV(1,y_norm,len);
		values[3*i+2] = ALT_CI_CI_DIV(1,z_norm,len);
	}
	// ############################################################################
	/*
	values[93] = ALT_CI_CI_DIV(0,6,6);
	values[94] = ALT_CI_CI_DIV(0,6,3);
	values[95] = ALT_CI_CI_DIV(0,6,2);
	values[93] = ALT_CI_CI_DIV(1,6,6);
	values[94] = ALT_CI_CI_DIV(1,6,3);
	values[95] = ALT_CI_CI_DIV(1,6,2);
	
	//alt_printf("%d", values[93]);
	
		values[93] = ALT_CI_CI_DIV(0,1,1);
		values[94] = ALT_CI_CI_DIV(0,2,2);
		values[95] = ALT_CI_CI_DIV(0,3,3);
		
		values[93] = ALT_CI_CI_DIV(1,1,1);
		values[94] = ALT_CI_CI_DIV(1,2,2);
		values[95] = ALT_CI_CI_DIV(1,3,3);*/


}

#endif
