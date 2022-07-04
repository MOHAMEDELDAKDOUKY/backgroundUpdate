#include "median_gpu.hpp"
#include <stdio.h>
#include <thrust/sort.h>


const int BLOCKDIM = 8;
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


__device__ void sort_insertion(uint8_t* x , int n_size)
{
    for(int k=1; k<n_size; k++)   
    {  
        int temp = x[k];  
        int j= k-1;  
        while(j>=0 && temp <= x[j])  
        {  
            x[j+1] = x[j];   
            j = j-1;  
        }  
        x[j+1] = temp;  
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

//#include <cub/cub.cuh>
#include <stdio.h>

const int ipt=8;
const int tpb=128;
const int blks = 1; 


__global__ void sort_kernel(uint8_t* windowMedian)
{
    // Specialize BlockRadixSort for a 1D block of 128 threads owning 8 integer items each
    typedef cub::BlockRadixSort<uint8_t, tpb, ipt> BlockRadixSort;
    // Allocate shared memory for BlockRadixSort
    __shared__ typename BlockRadixSort::TempStorage temp_storage;
    //Obtain a segment of consecutive items that are blocked across threads
    uint8_t thread_keys[ipt];

    for (int k = 0; k < ipt; k++) 
    {   
		//printf("\n %d", windowMedian[threadIdx.x * ipt + k]); 
        thread_keys[k] = windowMedian[threadIdx.x * ipt + k];
    }
    // Collectively sort the keys
    BlockRadixSort(temp_storage).Sort(thread_keys);
    __syncthreads();
    // write results to output array
    for (int k = 0; k < ipt; k++) 
       windowMedian[threadIdx.x * ipt + k] = thread_keys[k];
}



__global__ void across_frame_median_filter(uint8_t **recordDEV, int RECORD_LENGTH,
										   uint8_t *src_ptr, int src_pitch,
										   uint8_t *dst_ptr, int dst_pitch,
										   int dst_width, int dst_height,
										   int color_component)
{
    //printf("kernel >>>>>\n");

	const int x = blockIdx.x * blockDim.x + threadIdx.x;
	const int y = blockIdx.y * blockDim.y + threadIdx.y;
    //printf("kernel >>>> x: %d y: %d dst_width: %d dst_height: %d  color_component: %d\n ", x,y, dst_width, dst_height, color_component);
    
	uint8_t *windowMedian = (uint8_t*)malloc(RECORD_LENGTH * sizeof(uint8_t)); 

	if ((x < dst_width) && (y < dst_height))
	{
		int dst_offset = ((dst_pitch * y) + x * 4) + color_component;
		int src_offset = ((src_pitch * y) + x * 4) + color_component;

		int windowElements;

		for (windowElements = 0; windowElements < RECORD_LENGTH; windowElements++)
		{
			windowMedian[windowElements] = *(recordDEV[windowElements] + dst_offset);
		}

		
		sort_insertion(windowMedian,windowElements);

		for (windowElements = 0; windowElements < RECORD_LENGTH; windowElements++)
		{
			*(recordDEV[windowElements] + dst_offset) = windowMedian[windowElements]; 
		}

		free(windowMedian); 
	}
}


extern "C" void median_filter(NvBufSurface *src, NvBufSurface *dst,
							  std::vector<NvBufSurface *> record)
{
    int RECORD_LENGTH = record.size();

	uint8_t **recordCPU = (uint8_t **) malloc( RECORD_LENGTH* sizeof(uint8_t *));

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
		across_frame_median_filter<<<grid, block>>>(recordDEV, RECORD_LENGTH,  
												  src_ptr, src_pitch,
												  dst_ptr, dst_pitch,
												  output_cols, output_rows,
												  color_componenet);
	}
	
	cudaDeviceSynchronize();
    free(recordCPU);
	cudaFree(recordDEV);
}




// from here: https://stackoverflow.com/questions/64441827/cuda-thrustsort-met-memory-problem-when-i-still-have-enough-memory
// cudaError_t err = cudaDeviceSetLimit(cudaLimitMallocHeapSize, 1048576ULL*1024);

// __global__ void across_frame_median_filter(uint8_t **recordDEV, uint8_t *windowMedianDEV,
// 										   uint8_t *src_ptr, int src_pitch,
// 										   uint8_t *dst_ptr, int dst_pitch,
// 										   int dst_width, int dst_height,
// 										   int color_component)
// {
//     //printf("kernel >>>>>\n");

// 	const int x = blockIdx.x * blockDim.x + threadIdx.x;
// 	const int y = blockIdx.y * blockDim.y + threadIdx.y;
//     //printf("kernel >>>> x: %d y: %d dst_width: %d dst_height: %d  color_component: %d\n ", x,y, dst_width, dst_height, color_component);

// 	if ((x < dst_width) && (y < dst_height))
// 	{
// 		int dst_offset = ((dst_pitch * y) + x * 4) + color_component;
// 		int src_offset = ((src_pitch * y) + x * 4) + color_component;

// 		float windowMedian[RECORD_LENGTH];
// 		int windowElements;
//         // calling a __host__ function("thrust::device_vector<unsigned char,  ::thrust::device_allocator<unsigned char> > ::device_vector(unsigned long)") from a __global__ function("across_frame_median_filter") is not allowed
//         //thrust::device_vector<uint8_t> d_windowMedian(RECORD_LENGTH);

// 		for (windowElements = 0; windowElements < RECORD_LENGTH; windowElements++)
// 		{
// 			windowMedian[windowElements] = *(recordDEV[windowElements] + dst_offset);
// 		    //d_windowMedian.push_back(*(recordDEV[windowElements] + dst_offset));
// 	        //windowMedianDEV[windowElements] = *(recordDEV[windowElements] + dst_offset);

// 		}

// 	  	// cudaError_t status;
// 		// void* tmpStorage = 0;
// 		// size_t tmpStorageSize = 0;
// 		// uint8_t* d_keys = 0;
// 	    // unsigned dataSize = windowElements * sizeof(uint8_t);

// 		//allocateDeviceMemory( &d_keys , dataSize , __LINE__ );
// 	    //copyDataToDevice( d_keys , windowMedian , dataSize , __LINE__ );

// 		//status = cub::DeviceRadixSort::SortKeys(tmpStorage, tmpStorageSize, d_keys, d_keys, windowElements);
// 		//CHECK_ERROR( status );

// 		//allocateDeviceMemory( &tmpStorage , tmpStorageSize , __LINE__ );

// 		//status = cub::DeviceRadixSort::SortKeys(tmpStorage, tmpStorageSize, d_keys, d_keys, windowElements);
// 		//CHECK_ERROR( status );

// 		//copyDataToHost( h_keys , d_keys , dataSize , __LINE__ );

// 		thrust::sort(thrust::device, windowMedian, windowMedian + windowElements);
// 		//thrust::sort(thrust::device, windowMedianDEV, windowMedianDEV + windowElements);
// 		//thrust::sort(d_windowMedian.begin(), d_windowMedian.end());

// 		//sort_bubble(windowMedian, windowElements);
// 		//sort_linear(windowMedian,windowElements);
// 		///sort_quick(windowMedian,0,windowElements);
// 		//*(dst_ptr + dst_offset) = windowMedianDEV[windowElements / 2];
// 		//*(dst_ptr + dst_offset) = 0; //windowMedianGPU[0];
// 	    *(dst_ptr + dst_offset) = windowMedian[windowElements / 2];

// 	}
// }