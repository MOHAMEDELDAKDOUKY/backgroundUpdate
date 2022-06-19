# Locates the json_spirit library and include directories.

include(FindPackageHandleStandardArgs)
unset(TENSORRT_FOUND)

# Find include paths
find_path(TENSORRT_INCLUDE_DIR
          NvInfer.h
        HINTS
          /usr/local/tensorRT/include)

# Find library paths
find_library(NV_BUF_SURFACE_LIBRARY NAMES 
          nvbufsurface
        HINTS
          /opt/nvidia/deepstream/deepstream/lib)

find_library(NV_BUF_TRANSFORM_LIBRARY NAMES 
          nvbufsurftransform
        HINTS
          /opt/nvidia/deepstream/deepstream/lib)

# set NVDS_FOUND
find_package_handle_standard_args(NV_BUF_SURF            DEFAULT_MSG  NV_BUF_SURFACE_LIBRARY TENSORRT_INCLUDE_DIR)
find_package_handle_standard_args(NV_BUF_SURF_TRANSFORM  DEFAULT_MSG  NV_BUF_TRANSFORM_LIBRARY TENSORRT_INCLUDE_DIR)

if(NV_BUF_SURF_FOUND AND NV_BUF_SURF_TRANSFORM_FOUND)
        set(TENSORRT_FOUND TRUE)
        message("-- Found TensorRT!")
else()
        message(WARNING "Not all TensorRT packages were found!")
endif()

# set external variables for usage in CMakeLists.txt
if(TENSORRT_FOUND)
        set(TENSORRT_INCLUDE_DIRS ${TENSORRT_INCLUDE_DIR})    
        set(TENSORRT_LIBRARIES ${NV_BUF_SURFACE_LIBRARY} ${NV_BUF_TRANSFORM_LIBRARY})
endif()

# hide locals from GUI
mark_as_advanced(TENSORRT_INCLUDE_DIR)
mark_as_advanced(NV_BUF_SURFACE_LIBRARY)
mark_as_advanced(NV_BUF_TRANSFORM_LIBRARY)
