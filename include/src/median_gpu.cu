#include <iostream>
#include <cstdio>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <cuda_runtime.h>
#include "helper_cuda.h"

const int BLOCKDIM = 32;
const int MAX_WINDOW = 11;
//__device__ const int FILTER_SIZE = 9;
//__device__ const int FILTER_HALFSIZE = FILTER_SIZE >> 1;

__device__ void sort_quick(float *x, int left_idx, int right_idx) 
{
      int i = left_idx, j = right_idx;
      float pivot = x[(left_idx + right_idx) / 2];
      while (i <= j) 
      {
            while (x[i] < pivot)
                  i++;
            while (x[j] > pivot)
                  j--;
            if (i <= j) {
		  float temp;
                  temp = x[i];
                  x[i] = x[j];
                  x[j] = temp;
                  i++;
                  j--;
            }
      };
      if (left_idx < j)
            sort_quick(x, left_idx, j);
      if (i < right_idx)
            sort_quick(x, i, right_idx);
}

__device__ void sort_bubble(float *x, int n_size) 
{
	for (int i = 0; i < n_size - 1; i++) 
	{
		for(int j = 0; j < n_size - i - 1; j++) 
		{
			if (x[j] > x[j+1]) 
			{
				float temp = x[j];
				x[j] = x[j+1];
				x[j+1] = temp;
			}
		}
	}
}

__device__ void sort_linear(float *x, int n_size) 
{
	for (int i = 0; i < n_size-1; i++) 
	{
		int min_idx = i;
		for (int j = i + 1; j < n_size; j++) 
		{
			if(x[j] < x[min_idx])
				min_idx = j;
		}
		float temp = x[min_idx];
		x[min_idx] = x[i];
		x[i] = temp;
	}
}


__device__ int index(int x, int y, int width) 
{
	return (y * width) + x;
}


__global__ void median_filter_2d(unsigned char* input, unsigned char* output, int width, int height)
{
	const int x = blockIdx.x * blockDim.x + threadIdx.x;
	const int y = blockIdx.y * blockDim.y + threadIdx.y;
    printf("cuda+++++++++++++++++++++++++++++") ; 
	if((x<width) && (y<height))
	{
		const int color_tid = index(x,y,width);
		float windowMedian[MAX_WINDOW*MAX_WINDOW];
		int windowElements = 0;

			windowMedian[windowElements] = input[index(x,y,width)];
			windowMedian[windowElements++] = input[index(x,y,width)];
       
		sort_bubble(windowMedian,windowElements);
		//sort_linear(windowMedian,windowElements);
		//sort_quick(windowMedian,0,windowElements);
		output[color_tid] = windowMedian[windowElements/2];
	}
}

void median_filter_wrapper(const cv::Mat& input, cv::Mat& output)
{
	unsigned char *d_input, *d_output;
	
	cudaError_t cudaStatus;	
	
	cudaStatus = cudaMalloc<unsigned char>(&d_input,input.rows*input.cols);
	checkCudaErrors(cudaStatus);	
	cudaStatus = cudaMalloc<unsigned char>(&d_output,output.rows*output.cols);
	checkCudaErrors(cudaStatus);

	cudaStatus = cudaMemcpy(d_input,input.ptr(),input.rows*input.cols,cudaMemcpyHostToDevice);
	checkCudaErrors(cudaStatus);	
	
	const dim3 block(BLOCKDIM,BLOCKDIM);
	const dim3 grid(input.cols/BLOCKDIM, input.rows/BLOCKDIM);

	median_filter_2d<<<grid,block>>>(d_input,d_output,input.cols,input.rows);

	cudaStatus = cudaDeviceSynchronize();
	checkCudaErrors(cudaStatus);	

	cudaStatus = cudaMemcpy(output.ptr(),d_output,output.rows*output.cols,cudaMemcpyDeviceToHost);
	checkCudaErrors(cudaStatus);	

	cudaStatus = cudaFree(d_input);
	checkCudaErrors(cudaStatus);	
	cudaStatus = cudaFree(d_output);
	checkCudaErrors(cudaStatus);	
}


