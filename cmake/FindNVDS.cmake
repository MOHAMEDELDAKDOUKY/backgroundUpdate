# Locates the json_spirit library and include directories.

include(FindPackageHandleStandardArgs)
unset(NVDS_FOUND)

# Find include paths
set(DS_SRC_DIR "/opt/nvidia/deepstream/deepstream/sources")
find_path(NVDS_INCLUDE_DIR
          gstnvdsinfer.h
        HINTS
          ${DS_SRC_DIR}/includes)

find_path(NVDS_PREPROCESS_INCLUDE_LIBS_DIR
          nvdspreprocess_interface.h
        HINTS
          ${DS_SRC_DIR}/gst-plugins/gst-nvdspreprocess/include)

find_path(NVDS_INFER_DIR
          nvdsinfer_func_utils.h
        HINTS
          ${DS_SRC_DIR}/libs/nvdsinfer)

# Find library paths
set(NVDS_LIB_PATH "/opt/nvidia/deepstream/deepstream/lib/")
find_library(NVDS_HELPER_LIBRARY NAMES 
          nvdsgst_helper
        HINTS
          ${NVDS_LIB_PATH})

find_library(NVDS_GST_META_LIBRARY NAMES 
          nvdsgst_meta
        HINTS
          ${NVDS_LIB_PATH})

find_library(NVDS_META_LIBRARY NAMES 
          nvds_meta
        HINTS
          ${NVDS_LIB_PATH})

find_library(NVDS_INFER_LIBRARY NAMES 
          nvds_infer
        HINTS
          ${NVDS_LIB_PATH})

# set NVDS_FOUND
find_package_handle_standard_args(NVDS_HELPER         DEFAULT_MSG  NVDS_HELPER_LIBRARY)
find_package_handle_standard_args(NVDS_GST_META       DEFAULT_MSG  NVDS_GST_META_LIBRARY NVDS_INCLUDE_DIR) 
find_package_handle_standard_args(NVDS_META           DEFAULT_MSG  NVDS_META_LIBRARY NVDS_INCLUDE_DIR)
find_package_handle_standard_args(NVDS_INFER          DEFAULT_MSG  NVDS_INFER_LIBRARY NVDS_INFER_DIR)

if(NVDS_HELPER_FOUND AND NVDS_GST_META_FOUND AND NVDS_META_FOUND AND NVDS_INFER_FOUND)
        set(NVDS_FOUND TRUE)
        message("-- Found NVDS libs!")
else()
        message(WARNING "Not all NVDS packages were found!")
endif()

# set external variables for usage in CMakeLists.txt
if(NVDS_FOUND)
        set(NVDS_INCLUDE_DIRS ${NVDS_INCLUDE_DIR} ${NVDS_PREPROCESS_INCLUDE_LIBS_DIR} ${NVDS_INFER_DIR})    
        set(NVDS_LIBRARIES ${NVDS_HELPER_LIBRARY} ${NVDS_GST_META_LIBRARY} ${NVDS_META_LIBRARY} ${NVDS_INFER_LIBRARY})
endif()

# hide locals from GUI
mark_as_advanced(NVDS_INCLUDE_DIR)
mark_as_advanced(NVDS_INCLUDE_LIBS_DIR)
mark_as_advanced(NVDS_INCLUDE_GST_PLUGINS_DIR)
mark_as_advanced(NVDS_HELPER_LIBRARY)
mark_as_advanced(NVDS_GST_META_LIBRARY)
mark_as_advanced(NVDS_META_LIBRARY)
mark_as_advanced(NVDS_INFER_LIBRARY)
