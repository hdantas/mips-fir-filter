	.data
        
b:			.double 3.558363, -0.542859, -0.928322, -0.993428, 4.643953, -5.909149, 1.722120, -1.854375,
			.double -1.967672, -2.170269, 0.673272, 0.182548, -4.812593, 0.818270, 0.889598, 0.322937,
			.double -0.430576, -4.259421, -0.983597, 4.285341, -2.333795, 1.856496, -4.711222, -0.517585,
			.double -8.376492, -1.440117, -6.255069, -0.000203, 0.881922, 6.955272, -0.209273, 5.219892

x:			.double 0.286381, 0.310398, 0.732308, 0.301956, 0.053523, 0.431617, 0.999498, 0.801469,
			.double 0.639967, 0.293192, 0.404720, 0.823173, 0.695269, 0.744480, 0.676903, 0.968651,
			.double 0.524716, 0.843609, 0.562026, 0.297492, 0.384924, 0.379665, 0.087916, 0.535140,
			.double 0.224908, 0.136965, 0.186164, 0.811894, 0.010466, 0.754323, 0.227373, 0.296848,
			.double 0.064720, 0.959681, 0.598804, 0.118243, 0.391298, 0.598302, 0.919712, 0.031265,
			.double 0.891494, 0.324432, 0.854438, 0.586763, 0.068912, 0.531341, 0.555414, 0.593628,
			.double 0.374950, 0.117441, 0.891120, 0.759874, 0.497106, 0.979036, 0.295014, 0.722014,
			.double 0.116001, 0.481178, 0.533908, 0.126467, 0.235500, 0.761281, 0.423315, 0.300220
		
N: 		.word16 64       
MAX_TAP:	.word16 32
TAP:		.word16 8

string:	.asciiz "Result data:\n"
newline:	.asciiz "\n"

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
			
MAIN:		JAL FIR 						;fir_filter(y,b,x,N,TAP);

			DADDI $t7,$zero,4			;set for string output
			DADDI $t6,$zero,STRING	;printf("Result data:\n");
			SD $t6,$t8					
			SD $t7,$t9
			
			DADDI $t0,$zero,0			;i=0
FOR:		SLT $t1,$t0,N				;t1 = i < N
			BEQZ $t1,endFOR			;if (i >= N) goto endFOR
											;printf("%f\n%f\n\n", (double)i, y[i]);
			DADDI $t0,$t0,1			;i++
			J FOR							;iterate
endFOR:	HALT							;return 0




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

FIR:		DADDI $t0,$a4,-1			;t0 = i = tap - 1
			DADDI $t1,$a3,0			;t1 = n
	
FOR1:		SLT $t2,$t0,$t1			;t2 = t0 < t1 = i < n
			BEQZ $t2,endFOR1			;if (t0 >= t1) = if (i >= n) goto endFOR1
			LD $t3,($a1)				;t3 = b[0]
		
			DSLL $t2,$t0,3				;t2 = i << 3
			SD $t3,$t2($a0)			;y[i] = b[0]
		
			DADDI $t4,$zero,1			;t4 = j = 1

FOR2:		SLT $t5,$t4,$a4			;t5 = j < tap
			BEQZ $t5,endFOR2			;if (j >= tap) goto endFOR2
			
			DSLL $t5,$t4,3				;t5 = j << 3
			DSUB $t6,$t2,$t5			;t6 = i - j
			LD $t6,$t6($a2)			;t6 = x[i-j]

			LD $t5,$t5($a1)			;t5 = b[j]
			
			DMUL $t5,$t5,$t6			;t5 = b[j]*x[i-j]
			SD $t5,$t2($a0)			;y[i] = t5
		
			DADDI $t4,$t4,1			;j++
			J FOR2						;iterate
			
endFOR2:	DADDI $t0,$t0,1			;i++
			J FOR1						;iterate
endFOR1:									;return to MAIN using stack pointer
