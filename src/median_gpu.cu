#include "median_gpu.hpp"
#include <stdio.h>
#include <thrust/sort.h>

const int BLOCKDIM = 16;
//__device__ const int FILTER_SIZE = 9;
//__device__ const int FILTER_HALFSIZE = FILTER_SIZE >> 1;

__device__ void sort_quick(uint8_t *x, int left_idx, int right_idx)
{
	int i = left_idx, j = right_idx;
	uint8_t pivot = x[(left_idx + right_idx) / 2];
	while (i <= j)
	{
		while (x[i] < pivot)
			i++;
		while (x[j] > pivot)
			j--;
		if (i <= j)
		{
			uint8_t temp;
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

__device__ void sort_bubble(uint8_t *x, int n_size)
{
	for (int i = 0; i < n_size - 1; i++)
	{
		for (int j = 0; j < n_size - i - 1; j++)
		{
			if (x[j] > x[j + 1])
			{
				uint8_t temp = x[j];
				x[j] = x[j + 1];
				x[j + 1] = temp;
			}
		}
	}
}

__device__ void sort_insertion(uint8_t *x, int n_size)
{
	for (int k = 1; k < n_size; k++)
	{
		int temp = x[k];
		int j = k - 1;
		while (j >= 0 && temp <= x[j])
		{
			x[j + 1] = x[j];
			j = j - 1;
		}
		x[j + 1] = temp;
	}
}

__device__ void sort_linear(float *x, int n_size)
{
	for (int i = 0; i < n_size - 1; i++)
	{
		int min_idx = i;
		for (int j = i + 1; j < n_size; j++)
		{
			if (x[j] < x[min_idx])
				min_idx = j;
		}
		float temp = x[min_idx];
		x[min_idx] = x[i];
		x[i] = temp;
	}
}

__device__ void swap(uint8_t &a, uint8_t &b)
{
   uint8_t temp; 
   temp = a; 
   a = b; 
   b = temp; 
}

const int ipt = 8;
const int tpb = 128;
const int blks = 1;


__global__ void sort_kernel(uint8_t *windowMedian)
{
	// Specialize BlockRadixSort for a 1D block of 128 threads owning 8 integer items each
	typedef cub::BlockRadixSort<uint8_t, tpb, ipt> BlockRadixSort;
	// Allocate shared memory for BlockRadixSort
	__shared__ typename BlockRadixSort::TempStorage temp_storage;
	// Obtain a segment of consecutive items that are blocked across threads
	uint8_t thread_keys[ipt];

	for (int k = 0; k < ipt; k++)
	{
		// printf("\n %d", windowMedian[threadIdx.x * ipt + k]);
		thread_keys[k] = windowMedian[threadIdx.x * ipt + k];
	}
	// Collectively sort the keys
	BlockRadixSort(temp_storage).Sort(thread_keys);
	__syncthreads();
	// write results to output array
	for (int k = 0; k < ipt; k++)
		windowMedian[threadIdx.x * ipt + k] = thread_keys[k];
}


__global__ void temporal_median_filter(uint8_t **recordDEV,
									   uint8_t *src_ptr, int src_pitch,
									   uint8_t *dst_ptr, int dst_pitch,
									   int dst_width, int dst_height,
									   int color_component)
{
	//printf("kernel >>>>>\n");

	const int x = blockIdx.x * blockDim.x + threadIdx.x;
	const int y = blockIdx.y * blockDim.y + threadIdx.y;
	// printf("kernel >>>> x: %d y: %d dst_width: %d dst_height: %d  color_component: %d\n ", x,y, dst_width, dst_height, color_component);

	// uint8_t windowMedian[RECORD_LENGTH];
	uint8_t windowMedian[RECORD_LENGTH];

	if ((x < dst_width) && (y < dst_height))
	{
		int dst_offset = ((dst_pitch * y) + x * 4) + color_component;
		int src_offset = ((src_pitch * y) + x * 4) + color_component;

		int windowElements;

		for (windowElements = 0; windowElements < RECORD_LENGTH; windowElements++)
		{
			windowMedian[windowElements] = *(recordDEV[windowElements] + dst_offset);
			// printf(" %d, %d \n", windowMedian[windowElements] , *(recordDEV[windowElements] + dst_offset));
		}

		//sort_insertion(windowMedian,windowElements);
		
		// for 128 frame -> Time taken: 0.32s
		//thrust::sort(thrust::device, windowMedian, windowMedian + windowElements);
        
		// for 128 frame -> Time taken: 0.04s
		sort_bubble(windowMedian, windowElements);
		
		// sort_linear(windowMedian,windowElements);
		// sort_quick(windowMedian,0,windowElements);

		//sort_kernel<<<blks,tpb>>>(windowMedian);

		// printf("%d \n", (int)windowMedian[windowElements/2]);
		*(dst_ptr + dst_offset) = windowMedian[windowElements/2];
	}
}

extern "C" void median_filter(NvBufSurface *src, NvBufSurface *dst,
							  std::vector<NvBufSurface *> record)
{

	uint8_t *recordCPU[RECORD_LENGTH];

	for (int i = 0; i < RECORD_LENGTH; i++)
	{
		recordCPU[i] = (uint8_t *)record[i]->surfaceList->dataPtr;
	}

	uint8_t **recordDEV;
	cudaMalloc((uint8_t **)&recordDEV, RECORD_LENGTH * sizeof(uint8_t *));
	cudaMemcpy(recordDEV, recordCPU, RECORD_LENGTH * sizeof(uint8_t *), cudaMemcpyHostToDevice);

	uint8_t *src_ptr = (uint8_t *)src->surfaceList[0].dataPtr;
	int src_pitch = src->surfaceList[0].pitch;

	uint8_t *dst_ptr = (uint8_t *)dst->surfaceList[0].dataPtr;
	int output_cols = dst->surfaceList[0].width;
	int output_rows = dst->surfaceList[0].height;
	int dst_pitch = dst->surfaceList[0].pitch;

	printf("output_rows: %d output_cols: %d dst_pitch: %d src_pitch: %d \n ", output_rows, output_cols, dst_pitch, src_pitch);

	const dim3 block(BLOCKDIM, BLOCKDIM);
	const dim3 grid(output_cols / BLOCKDIM, output_rows / BLOCKDIM);

	for (int color_componenet = 0; color_componenet <= 4; color_componenet++)
	{
		temporal_median_filter<<<grid, block>>>(recordDEV,
												src_ptr, src_pitch,
												dst_ptr, dst_pitch,
												output_cols, output_rows,
												color_componenet);
	}

	cudaDeviceSynchronize();

	cudaFree(recordDEV);
}
