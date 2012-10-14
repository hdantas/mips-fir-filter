	.data

N: 		.word16 64       
MAXTAP:	.word16 32
TAP:		.word16 8

y:			.space 512 ;8*N

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
			.double -0.430576
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

FPZERO:	.double 0.0
FPONE:	.double 1.0
STRING:	.asciiz "Result data:\n"
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


			
        
FIR:		
			LD $t9,TAP($zero)			;t9 = TAP
			LD $t8,N($zero)			;t8 = N
			LD $t7,b($zero)			;t7 = b[0]
			DADDI $t0,$t9,-1			;t0 = i = TAP - 1

; initialize all elements of y as: y[i] = b[0]; where i: tap - 1 <= i < N
			SLT $t3,$t0,$t8			;t3 = i < N

FOR1:		DSLL $t4,$t0,3				;t4 = i << 3			
			BEQZ $t3,endFOR1			;if (i >= N) goto endFOR1

			DADDUI $t0,$t0,1			;i++
			SD $t7,y($t4)				;y[i-1] = b[0]
			J FOR1
			SLT $t3,$t0,$t8			;t3 = i < N executed because of delay slot
endFOR1:		
			

; the outer loop assigns b[j] to F0 so that it is used in the inner loop, this way b[j] is only read once for each j. Please see fir_filter_optimized.c.
			DADDI $t1,$zero,1			;t1 = j = 1

FOR2:		SLT $t3,$t1,$t9			;t3 = j < TAP
			DSLL $t4,$t1,3				;t4 = j << 3
			BEQZ $t3,endFOR2			;if (j >= TAP) goto endFOR2
			
			DADDI $t0,$t9,-1			;t0 = i = TAP - 1
			L.D F0,b($t4)				;F0 = b[j]
			DSLL $t5,$t0,3				;t5 = i << 3
			
FOR3:		SLT $t3,$t0,$t8			;t3 = i < N
			DSUB $t6,$t5,$t4			;t6 = 8*(i - j) = 8*i - 8*j
			BEQZ $t3,endFOR3			;if (i >= N) goto endFOR3
			
			DADDUI $t0,$t0,1			;i++
			L.D F1,x($t6)				;F1 = x[i-j]			
			L.D F3,y($t5)				;F3 = y[i]		
			
			MUL.D F2,F0,F1				;F2 = b[j]*x[i-j]
			ADD.D F4,F3,F2				;F4 = y[i] + b[j]*x[i-j]
			S.D F4,y($t5)				;y[i] += temp*x[i-j] 
			
			J FOR3						;iterate
			DSLL $t5,$t0,3				;t5 = i << 3
endFOR3:	
			J FOR2					;iterate
			DADDUI $t1,$t1,1		;j++ executes because of delay slot
endFOR2:

MAIN:		LWU $t8,DATA($zero)		;$t8 = address of DATA register
			LWU $t9,CONTROL($zero)	;$t9 = address of CONTROL register

			DADDUI $t2,$zero,1			;set for unsigned integer to be output
			DADDUI $t3,$zero,3			;set for floating point to be output
			DADDUI $t4,$zero,4			;set for string output
			DADDUI $t6,$zero,STRING		;printf("Result data:\n");
			DADDUI $t5,$zero,NEWLINE	;printf("\n");

			SD $t6,($t8)	;print text STRING
			SD $t4,($t9)	;print as string
					
			L.D F1,FPZERO($zero)
			L.D F2,FPONE($zero)

			DADDUI $t7,$zero,3	;t7 = j = 3 loop counter
			DADDUI $t0,$zero,0	;t0 = i = 0
			DADDUI $t1,$zero,y	;t1 = &y[0]	
			LD $a1,y($zero)
PRINT:	BEQZ $t7,END ;print 3 times 21 elements plus 1 to cover the all 64 elements of y (21*3 + 1 = 64)	
		
		L.D F0,0($t1)	;load y[0]
		SD $t0,($t8)	;print i
		SD $t2,($t9)	;print as unsigned integer
		DADDUI $t0,$t0,1	;icrement i
		S.D F0,($t8)	;print y[0]
		SD $t3,($t9)	;print as double
		SD $t5,($t8)	;print a new line
		SD $t4,($t9)	;print as string

L.D F0,8($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,16($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,24($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,32($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,40($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,48($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,56($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,64($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,72($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,80($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,88($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,96($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,104($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,112($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,120($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,128($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,136($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,144($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,152($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)

L.D F0,160($t1)
SD $t0,($t8)
SD $t2,($t9)
DADDUI $t0,$t0,1
S.D F0,($t8)
SD $t3,($t9)
SD $t5,($t8)
SD $t4,($t9)



			DADDUI $t7,$t7,-1	;i-- 
			J PRINT	
			DADDUI $t1,$t1,168	;t1 = &y[8*21] executes because of delay slot	

END:		L.D F0,0($t1)
			SD $t0,($t8)
			SD $t2,($t9)
			S.D F0,($t8)
			SD $t3,($t9)
			HALT						;return 0



