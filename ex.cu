// include any headers
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

// define constants
#define RADIUS 3
#define BLOCK_SIZE 256

// function to apply a 1d stencil to an array
__global__ void stencil_1d(int *in, int *out, int len) {
  __shared__ int temp[BLOCK_SIZE + 2 * RADIUS];
  int gindex = threadIdx.x + blockIdx.x * blockDim.x;
  int lindex = threadIdx.x + RADIUS;

  temp[lindex] = in[gindex];
  if (threadIdx.x < RADIUS){ //checks if lower than radius, aka will go off end
    
    if(gindex-RADIUS < 0){
      temp[lindex-RADIUS]=0;
    }
    else{

    temp[lindex - RADIUS] = in[gindex - RADIUS];
    }
    // I think this fixes boundary problem...?
    if (gindex + BLOCK_SIZE < len) {
        temp[lindex + BLOCK_SIZE] = in[gindex + BLOCK_SIZE]; // Right neighbor
    } else {
        temp[lindex + BLOCK_SIZE] = 0; // Padding for out-of-bounds (right side)
    }
  //   if(gindex > len){ //WRONG boooo :() padding to the right wrong
  //     temp[lindex]=0;
  //   }
  //   else{
  //   temp[lindex + BLOCK_SIZE] = in[gindex + BLOCK_SIZE];
  // }
  }

  //test statement

  __syncthreads();
  //apply stencil I think....????
  int result = 0;
  for(int offset =- RADIUS ; offset <= RADIUS ; offset++)
    result += temp[lindex + offset];

  out[gindex] = result;

}

int main(void) {
  // allocate input and output arrays
  int N = 1<<20; // 1M elements
  N=526;
  int *input, *output;
  cudaMallocManaged(&input, N*sizeof(int));
  cudaMallocManaged(&output, N*sizeof(int));

  // initialize input array on the host
  for(int i=0; i<N; i++){
    //if all ones
    input[i]=1;
    printf("%d ", input[i]);
    
  }
  printf("\n");

  // run the kernel
  //Initializing block size and running kernerl
  int blocksPerGrid = (N + BLOCK_SIZE - 1) / BLOCK_SIZE; 
  int threadsPerBlock = BLOCK_SIZE;
  

  stencil_1d<<<blocksPerGrid, threadsPerBlock>>>(input, output, N);
  cudaDeviceSynchronize();


  // check results
  for (int i = 0; i < N; i++) {
    printf("%d ", output[i]);
  }
  printf("\n");

  printf("%s\n", cudaGetErrorString(cudaGetLastError()));

  // Check for errors (from add, where all values should be 3.0f)
  // float maxError = 0.0f;
  // for (int i = 0; i < N; i++){
  //   maxError = fmax(maxError, fabs(y[i]-3.0f));
  // std::cout << "Max error: " << maxError << std::endl;
  // }

  // free memory
  cudaFree(input);
  cudaFree(output);

  return 0;
}