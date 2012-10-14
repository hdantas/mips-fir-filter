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
#define N 128
#define MAX_TAP 64
#define TAP 8

int main (){
	double y[N];
	double b[MAX_TAP] = {
		3.558363, -0.542859, -0.928322, -0.993428, 4.643953, -5.909149, 1.722120, -1.854375,
		-1.967672, -2.170269, 0.673272, 0.182548, -4.812593, 0.818270, 0.889598, 0.322937,
		-0.430576, -4.259421, -0.983597, 4.285341, -2.333795, 1.856496, -4.711222, -0.517585,
		-8.376492, -1.440117, -6.255069, -0.000203, 0.881922, 6.955272, -0.209273, 5.219892,
		-2.510238, 8.047002, -2.056733, 0.424163, -1.853738, -6.988925, 3.035232, 2.558813,
		-2.312757, 3.378699, -1.458246, -4.500422, -0.199605, -2.525149, 6.718932, -4.653600,
		0.921244, 0.329533, -2.790818, 0.826192, -3.725280, -2.179197, 2.896615, -3.283461,
		-2.467862, 2.663645, 0.148206, -1.884430, 1.213841, 0.865318, 0.303099, 0.968887 };
	
	double x[N] = {
		0.286381, 0.310398, 0.732308, 0.301956, 0.053523, 0.431617, 0.999498, 0.801469,
		0.639967, 0.293192, 0.404720, 0.823173, 0.695269, 0.744480, 0.676903, 0.968651,
		0.524716, 0.843609, 0.562026, 0.297492, 0.384924, 0.379665, 0.087916, 0.535140,
		0.224908, 0.136965, 0.186164, 0.811894, 0.010466, 0.754323, 0.227373, 0.296848,
		0.064720, 0.959681, 0.598804, 0.118243, 0.391298, 0.598302, 0.919712, 0.031265,
		0.891494, 0.324432, 0.854438, 0.586763, 0.068912, 0.531341, 0.555414, 0.593628,
		0.374950, 0.117441, 0.891120, 0.759874, 0.497106, 0.979036, 0.295014, 0.722014,
		0.116001, 0.481178, 0.533908, 0.126467, 0.235500, 0.761281, 0.423315, 0.300220,
		0.720962, 0.022119, 0.418464, 0.112259, 0.620420, 0.338176, 0.143524, 0.511914,
		0.662608, 0.997962, 0.098678, 0.731520, 0.529303, 0.654092, 0.325148, 0.904253,
		0.771533, 0.216268, 0.664127, 0.268639, 0.195304, 0.959141, 0.990653, 0.311305,
		0.440318, 0.524561, 0.437773, 0.675819, 0.285841, 0.861087, 0.976039, 0.006803,
		0.883206, 0.394503, 0.119062, 0.503626, 0.732678, 0.262587, 0.015541, 0.395286,
		0.260549, 0.114219, 0.126806, 0.789852, 0.768311, 0.451953, 0.694104, 0.539844,
		0.668221, 0.358231, 0.808483, 0.863526, 0.317372, 0.799136, 0.174831, 0.757690,
		0.323697, 0.612604, 0.433509, 0.609538, 0.473691, 0.409548, 0.616341, 0.356897 };

	int i;
	
	fir_filter(y,b,x,1,TAP);
	printf("Result data:\n");
	for(i=0; i < 1; i++)
		printf("%f %f\n", (double)i, y[i]);
	printf("end\n");
	return 0;
}

