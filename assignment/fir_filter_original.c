#include <stdio.h>
//
// This implements an n-tap FIR filter that takes an array of doubles x[] and calculates
// a weighted sum using the coefficients in b[] for each output element in y[].
//
void fir_filter(double y[], double b[], double x[], int n, int tap)
{
	int i, j;
	for(i = tap - 1; i < n; i = i + 1)
	{
		y[i] = b[0];
		for(j = 1; j < tap; j++)
			y[i] += b[j]*x[i-j];
	}
}

//
// The main method contains several big arrays. Two of them are initialized with many values
// in *.s files you do this like:
// .ARRAY_X .double 0.3,45.2,11.2, etc.
#define N 64
#define MAX_TAP 32
#define TAP 8

int main (){
	double y[N];
	double b[MAX_TAP] = {
		3.558363, -0.542859, -0.928322, -0.993428, 4.643953, -5.909149, 1.722120, -1.854375,
		-1.967672, -2.170269, 0.673272, 0.182548, -4.812593, 0.818270, 0.889598, 0.322937,
		-0.430576, -4.259421, -0.983597, 4.285341, -2.333795, 1.856496, -4.711222, -0.517585,
		-8.376492, -1.440117, -6.255069, -0.000203, 0.881922, 6.955272, -0.209273, 5.219892 };
	
	double x[N] = {
		0.286381, 0.310398, 0.732308, 0.301956, 0.053523, 0.431617, 0.999498, 0.801469,
		0.639967, 0.293192, 0.404720, 0.823173, 0.695269, 0.744480, 0.676903, 0.968651,
		0.524716, 0.843609, 0.562026, 0.297492, 0.384924, 0.379665, 0.087916, 0.535140,
		0.224908, 0.136965, 0.186164, 0.811894, 0.010466, 0.754323, 0.227373, 0.296848,
		0.064720, 0.959681, 0.598804, 0.118243, 0.391298, 0.598302, 0.919712, 0.031265,
		0.891494, 0.324432, 0.854438, 0.586763, 0.068912, 0.531341, 0.555414, 0.593628,
		0.374950, 0.117441, 0.891120, 0.759874, 0.497106, 0.979036, 0.295014, 0.722014,
		0.116001, 0.481178, 0.533908, 0.126467, 0.235500, 0.761281, 0.423315, 0.300220 };

	int i;
	
	fir_filter(y,b,x,N,TAP);
	printf("Result data:\n");
	for(i=0; i < N; i++)
		printf("%f %f\n", (double)i, y[i]);
	printf("end\n");
	return 0;
}

