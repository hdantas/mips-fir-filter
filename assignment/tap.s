	.data

N: 			.word16 64       
MAX_TAP:	.word16 32
TAP:		.word16 8

y:			.space 64
b:			.double	3.558363
			.double -0.542859
			.double -0.928322
			.double -0.993428
			.double 4.643953
			.double -5.909149
			.double 1.722120
			.double -1.854375
			.double -1.967672
			.double -2.170269
			.double 0.673272
			.double 0.182548
			.double -4.812593
			.double 0.818270
			.double 0.889598
			.double 0.322937
			.double	-0.430576
			.double -4.259421
			.double -0.983597
			.double 4.285341
			.double -2.333795
			.double 1.856496
			.double -4.711222
			.double -0.517585
			.double -8.376492
			.double -1.440117
			.double -6.255069
			.double -0.000203
			.double 0.881922
			.double 6.955272
			.double -0.209273
			.double 5.219892

x:			.double	0.286381
			.double 0.310398
			.double 0.732308
			.double 0.301956
			.double 0.053523
			.double 0.431617
			.double 0.999498
			.double 0.801469
			.double 0.639967
			.double 0.293192
			.double 0.404720
			.double 0.823173
			.double 0.695269
			.double 0.744480
			.double 0.676903
			.double 0.968651
			.double 0.524716
			.double 0.843609
			.double 0.562026
			.double 0.297492
			.double 0.384924
			.double 0.379665
			.double 0.087916
			.double 0.535140
			.double 0.224908
			.double 0.136965
			.double 0.186164
			.double 0.811894
			.double 0.010466
			.double 0.754323
			.double 0.227373
			.double 0.296848
			.double 0.064720
			.double 0.959681
			.double 0.598804
			.double 0.118243
			.double 0.391298
			.double 0.598302
			.double 0.919712
			.double 0.031265
			.double 0.891494
			.double 0.324432
			.double 0.854438
			.double 0.586763
			.double 0.068912
			.double 0.531341
			.double 0.555414
			.double 0.593628
			.double 0.374950
			.double 0.117441
			.double 0.891120
			.double 0.759874
			.double 0.497106
			.double 0.979036
			.double 0.295014
			.double 0.722014
			.double 0.116001
			.double 0.481178
			.double 0.533908
			.double 0.126467	
			.double 0.235500
			.double 0.761281
			.double 0.423315
			.double 0.300220

STRING:		.asciiz "Result data:\n"
NEWLINE:	.asciiz "\n"

;
; Memory Mapped I/O area
;
; Address of CONTROL and DATA registers
;
; Set CONTROL = 1, Set DATA to Unsigned Integer to be output
; Set CONTROL = 2, Set DATA to Signed Integer to be output
; Set CONTROL = 3, Set DATA to Floating Point to be output
; Set CONTROL = 4, Set DATA to address of string to be output
; Set CONTROL = 5, Set DATA+5 to x coordinate, DATA+4 to y coordinate, and DATA to RGB colour to be output
; Set CONTROL = 6, Clears the terminal screen
; Set CONTROL = 7, Clears the graphics screen
; Set CONTROL = 8, read the DATA (either an integer or a floating-point) from the keyboard
; Set CONTROL = 9, read one byte from DATA, no character echo.
;

CONTROL:	.word32 0x10000
DATA:		.word32 0x10008

	.text

;	fir_filter(y,b,x,N,TAP);
;	printf("Result data:\n");
;	for(i=0; i < N; i++)
;		printf("%f %f\n", (double)i, y[i]);
;	printf("end\n");
;	return 0;

			LWU $t8,DATA($zero)		;$t8 = address of DATA register
			LWU $t9,CONTROL($zero)	;$t9 = address of CONTROL register
			DADDI $sp,$zero,0x180	;position a stack in data memory 0x140 is enough for 6*64bit numbers
						
			SD $ra,($sp)					
			DADDI $sp,$sp,64		;push return address onto stack			
			
			DADDI $t0,$zero,y
			SD $t0,($sp)
			DADDI $sp,$sp,64		;push y onto stack
			
			DADDI $t0,$zero,b
			SD $t0,($sp)
			DADDI $sp,$sp,64		;push b onto stack			
			
			DADDI $t0,$zero,x
			SD $t0,($sp)
			DADDI $sp,$sp,64		;push x onto stack		
			
			DADDI $t0,$zero,N
			SD $t0,($sp)
			DADDI $sp,$sp,64		;push N onto stack
			
			DADDI $t0,$zero,TAP
			SD $t0,($sp)		
			DADDI $sp,$sp,64		;push TAP onto stack
			
			JAL FIR 				;fir_filter(y,b,x,N,TAP);
MAIN:		DADDI $sp,$sp,-64		;pop tap off the stack
			
			DADDI $sp,$sp,-64		;pop n off the stack
			
			DADDI $sp,$sp,-64		;pop x off the stack
			
			DADDI $sp,$sp,-64		;pop b off the stack
			
			DADDI $sp,$sp,-64		;pop y off the stack
			LD $a0,($sp)
			
			DADDI $t7,$zero,4		;set for string output
			DADDI $t6,$zero,STRING	;printf("Result data:\n");
			SD $t6,($t8)
			SD $t7,($t9)
			
			
			
			DADDUI $t0,$zero,0		;i=0
FOR:		SLTIU $t1,$t0,N			;t1 = i < N
			BEQZ $t1,endFOR			;if (i >= N) goto endFOR
			
			DADDUI $t7,$zero,3		;set for floating point to be output
			DADDUI $t6,$t0,0			;printf("%f\n" (double)i);
			SD $t6,($t8)
			SD $t7,($t9)
			
			DSLL $t2,$t0,3			;t2 = i << 3
			DADD $t2,$a0,$t2	;t2 = &y[i]
			LD $t2,($t2)			;t2 = y[i]
			DADDUI $t6,$t2,0	;printf("%f\n" y[i]);
			SD $t6,($t8)		
			SD $t7,($t9)
			
			DADDUI $t7,$zero,4		;set for string output
			DADDUI $t6,$zero,NEWLINE	;printf("Result data:\n");
			SD $t6,($t8)
			SD $t7,($t9)

			DADDUI $t0,$t0,1			;i++
			J FOR					;iterate
endFOR:		HALT						;return 0




;
; This implements an n-tap FIR filter that takes an array of doubles x[] and calculates
; a weighted sum using the coefficients in b[] for each output element in y[].
;
; void fir_filter(double y[], double b[], double x[], int n, int tap)
; {
; int i, j;
; for(i = tap - 1; i < n; i = i + 1)
; {
; 	y[i] = b[0]
; 	for(j = 1; j < tap; j++)
;		y[i] += b[j]*x[i-j];
; 	}
; }

        
FIR:		DADDI $sp,$sp,-64		;pop tap off the stack
			LD $t0,($sp)
			DADDI $sp,$sp,-64		;pop n off the stack
			LD $a3,($sp)
			DADDI $sp,$sp,-64		;pop x off the stack
			LD $a2,($sp)
			DADDI $sp,$sp,-64		;pop b off the stack
			LD $a1,($sp)
			DADDI $sp,$sp,-64		;pop y off the stack
			LD $a0,($sp)
			
			DADDI $t1,$t0,-1		;t1 = i = tap - 1
				
FOR1:		SLT $t2,$t1,$a3		;t2 = t1 < a3 = i < n
			BEQZ $t2,endFOR1		;if (t1 >= a3) = if (i >= n) goto endFOR1
			LD $t3,($a1)			;t3 = b[0]
		
			DSLL $t2,$t1,3			;t2 = i << 3
			DADD $t2,$a0,$t2		;t2 = &y[i]
			SD $t3,($t2)			;y[i] = b[0]
		
			DADDUI $t4,$zero,1	;t4 = j = 1

FOR2:		SLT $t5,$t4,$t0		;t5 = j < tap
			BEQZ $t5,endFOR2		;if (j >= tap) goto endFOR2
			
			DSLL $t5,$t4,3			;t5 = j << 3
			DADD $t5,$a1,$t5		;t5 = &b[j]
			LD $t5,($t5)			;t5 = b[j]

			DSUB $t6,$t1,$t4		;t6 = i - j
			DSLL $t6,$t6,3			;t6 = (i - j) << 3
			DADD $t6,$a2,$t6		;t6 = &x[i-j]
			LD $t6,($t6)			;t6 = x[i-j]
			
			DMUL $t5,$t5,$t6		;t5 = b[j]*x[i-j]
			
			LD $t6,($t2)			;t6 = y[i]
			DADD $t6,$t6,$t5		;t6 = y[i] + b[j]*x[i-j]
			SD $t6,($t2)			;y[i] = t6 = y[i] + b[j]*x[i-j]
		
			DADDUI $t4,$t4,1		;j++
			J FOR2					;iterate
			
endFOR2:	DADDUI $t1,$t1,1			;i++
			J FOR1					;iterate

endFOR1:	DADDI $sp,$sp,-64		;pop return address off the stack
			LD $ra,($sp)			;ra -> return address

			SD $a0,($sp)
			DADDUI $sp,$sp,64		;push y onto stack
			SD $a1,($sp)
			DADDUI $sp,$sp,64		;push b onto stack					
			SD $a2,($sp)
			DADDUI $sp,$sp,64		;push x onto stack	
			SD $a3,($sp)
			DADDUI $sp,$sp,64		;push N onto stack
			SD $t0,($sp)			
			DADDUI $sp,$sp,64		;push TAP onto stack
			JR $ra					;return to MAIN
