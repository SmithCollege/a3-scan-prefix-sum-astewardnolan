#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <sys/time.h>

#define BLOCK_SIZE 128

__global__ void recursive_doubling(int *in, int *out, int SIZE) {
    int tIdx = threadIdx.x + blockIdx.x * blockDim.x;

    if (tIdx < SIZE) {
        out[tIdx] = in[tIdx]; 
    }
    __syncthreads(); 

    // recursive doubling part
    for (int offset = 1; offset < SIZE; offset *= 2) {
        if (tIdx >= offset) {
            out[tIdx] += out[tIdx - offset]; // Accumulatez values
        }
        __syncthreads(); 
    }
}

void initialize_data(int *in, int SIZE) {
    for (int i = 0; i < SIZE; ++i) {
        in[i] = i + 1;  
    }
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
  int *in, *out;

  cudaMallocManaged(&in, SIZE*sizeof(int));
  cudaMallocManaged(&out, SIZE*sizeof(int));

  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    in[i] = 1;
   }

  initialize_data(in, SIZE); // Initialize data with 1, 2, ..., N

  double start = get_clock();
//checks og
  printf("\n");

      // run the kernel
  //Initializing block size and running kernerl
  int blocksPerGrid = (SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE; 
  int threadsPerBlock = BLOCK_SIZE;


  recursive_doubling<<<blocksPerGrid, threadsPerBlock>>>(in, out, SIZE);
  cudaDeviceSynchronize();

  double end = get_clock();
  printf("time per call: %f ns\n", (end-start) );
  // check results
  for (int i = 0; i < SIZE; i++) {
    printf("%d ", out[i]);
  }
  printf("\n");

  printf("%s\n", cudaGetErrorString(cudaGetLastError()));

  cudaFree(in);
  cudaFree(out);
  return 0;


}
