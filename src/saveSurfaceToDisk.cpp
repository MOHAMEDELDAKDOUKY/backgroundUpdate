#include "saveSurfaceToDisk.hpp"

NvBufSurface *saveSurfaceToDisk(NvBufSurface *surface) {
  static int dump = 0;
  int batch_size = surface->batchSize;
  printf("\nBatch Size : %d, resolution : %dx%d \n", batch_size, surface->surfaceList[0].width,
         surface->surfaceList[0].height);

  NvBufSurfTransformRect src_rect;
  NvBufSurfTransformRect dst_rect;

  src_rect.top = 0;
  src_rect.left = 0;
  src_rect.width = (uint)surface->surfaceList[0].width/2;
  src_rect.height = (uint)surface->surfaceList[0].height/2;

  dst_rect.top = 0;
  dst_rect.left = 0;
  dst_rect.width = (uint)surface->surfaceList[0].width;
  dst_rect.height = (uint)surface->surfaceList[0].height;

  NvBufSurfTransformParams nvbufsurface_params;
  nvbufsurface_params.src_rect = &src_rect;
  nvbufsurface_params.dst_rect = &dst_rect;
  nvbufsurface_params.transform_flag =
      NVBUFSURF_TRANSFORM_FILTER | NVBUFSURF_TRANSFORM_CROP_SRC | NVBUFSURF_TRANSFORM_CROP_DST;
  nvbufsurface_params.transform_filter = NvBufSurfTransformInter_Default;

  NvBufSurface *dst_surface = NULL;
  NvBufSurfaceCreateParams nvbufsurface_create_params;

  /* An intermediate buffer for NV12/RGBA to BGR conversion  will be
   * required. Can be skipped if custom algorithm can work directly on NV12/RGBA. */
  nvbufsurface_create_params.gpuId = surface->gpuId;
  nvbufsurface_create_params.width = (int)surface->surfaceList[0].width;
  nvbufsurface_create_params.height = (int)surface->surfaceList[0].height;
  nvbufsurface_create_params.size = 0;
  nvbufsurface_create_params.colorFormat = NVBUF_COLOR_FORMAT_RGBA;
  nvbufsurface_create_params.layout = NVBUF_LAYOUT_PITCH;
  nvbufsurface_create_params.memType = NVBUF_MEM_CUDA_PINNED;

  int create_result = NvBufSurfaceCreate(&dst_surface, batch_size, &nvbufsurface_create_params);

  NvBufSurfTransformConfigParams transform_config_params;
  NvBufSurfTransform_Error err;
  
  cudaStream_t cuda_stream; 
  
  transform_config_params.compute_mode = NvBufSurfTransformCompute_Default;
  transform_config_params.gpu_id = surface->gpuId;
  transform_config_params.cuda_stream = cuda_stream;
  err = NvBufSurfTransformSetSessionParams(&transform_config_params);

  NvBufSurfaceMemSet(dst_surface, 0, 0, 0);
  err = NvBufSurfTransform(surface, dst_surface, &nvbufsurface_params);
  if (err != NvBufSurfTransformError_Success) {
    printf("NvBufSurfTransform failed with error %d while converting buffer\n", err);
  }
  NvBufSurfaceMap(dst_surface, 0, 0, NVBUF_MAP_READ);
  NvBufSurfaceSyncForCpu(dst_surface, 0, 0);

  cv::Mat bgr_frame = cv::Mat(cv::Size(nvbufsurface_create_params.width, nvbufsurface_create_params.height), CV_8UC3);

  cv::Mat in_mat = cv::Mat(nvbufsurface_create_params.height, nvbufsurface_create_params.width, CV_8UC4,
                           dst_surface->surfaceList[0].mappedAddr.addr[0], dst_surface->surfaceList[0].pitch);

  cv::cvtColor(in_mat, bgr_frame, cv::COLOR_RGBA2BGR);

  char filename[64];
  snprintf(filename, 64, "images/image%03d.jpg", dump);
  cv::imwrite(filename, bgr_frame);
  dump++;

  NvBufSurfaceUnMap(dst_surface, 0, 0);

  // Will distroy stream
  //NvBufSurfaceDestroy(dst_surface);
  // cudaStreamDestroy(cuda_stream);

  return dst_surface;
}
