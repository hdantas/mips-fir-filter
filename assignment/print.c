#include <stdio.h>

	int main() {
		int i;
		for (i=1;i<32;i++){
			printf("L.D F0,%d($t1)\nSD $t0,($t8)\nSD $t2,($t9)\nDADDUI $t0,$t0,1\nS.D F0,($t8)\nSD $t3,($t9)\nSD $t5,($t8)\nSD $t4,($t9)\n\n",i*8);
		}
	return 0;
}
