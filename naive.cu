// include any headers
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <sys/time.h>

// define constants
#define BLOCK_SIZE 128

__global__ void scan(int *in, int *out, int len) { //need kernel  function
    int gindex = threadIdx.x + blockIdx.x * blockDim.x;

    if(gindex >= len){
        return;
    }

    for (int i = 0; i < len; i++) {
        int value = 0;
        for (int j = 0; j <= i; j++) {
            value += in[j];
   }
    out[i] = value;
  }
    __syncthreads();
}

double get_clock() {
    struct timeval tv; int ok;
    ok = gettimeofday(&tv, (void *) 0);
    if (ok<0) { 
        printf("gettimeofday error"); 
        }
    return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main(void) {
  // allocate input and output arrays
  int SIZE = 1<<20; // 1M elements
  SIZE=128;
  int *input, *output;
  cudaMallocManaged(&input, SIZE*sizeof(int));
  cudaMallocManaged(&output, SIZE*sizeof(int));

  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    input[i] = 1;
   }
    double start = get_clock();
//checks og
  printf("\n");

      // run the kernel
  //Initializing block size and running kernerl
  int blocksPerGrid = (SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE; 
  int threadsPerBlock = BLOCK_SIZE;


  scan<<<blocksPerGrid, threadsPerBlock>>>(input, output, SIZE);
  cudaDeviceSynchronize();

  double end = get_clock();
  printf("time per call: %f ns\n", (end-start) );
  // check results
  for (int i = 0; i < SIZE; i++) {
    printf("%d ", output[i]);
  }
  printf("\n");

  printf("%s\n", cudaGetErrorString(cudaGetLastError()));

  cudaFree(input);
  cudaFree(output);
  return 0;


}
