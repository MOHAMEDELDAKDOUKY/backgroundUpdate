project(backgroundupdateplugin LANGUAGES CXX CUDA)
cmake_minimum_required(VERSION 3.2)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
        "Choose the type of build, options are: Debug Release
        RelWithDebInfo MinSizeRel."
        FORCE)
endif(NOT CMAKE_BUILD_TYPE)

if(DEFINED ENV{CI_COMMIT_TAG})
    set(PROJECT_VERSION $ENV{CI_COMMIT_TAG})
else()
    set(PROJECT_VERSION "0.0.0-test" CACHE STRING "Version number")
endif()

set(PACKAGE_CONFIG_PATH "/usr/lib/x86_64-linux-gnu/pkgconfig" CACHE STRING "pkgconfig path of gstreamer")
set(CMAKE_INSTALL_PREFIX "/usr/local/lib/")
if(${PACKAGE_CONFIG_PATH} MATCHES " ")
    MESSAGE(WARNING "You may want to specify pkgconfig path of gstreamer using -DPACKAGE_CONFIG_PATH")
endif(${PACKAGE_CONFIG_PATH} MATCHES " ")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_subdirectory("/home/avidbeam/dakdouky_ws/atun-gstreamer-runtime/avidgstmeta" /home/avidbeam/dakdouky_ws/atun-gstreamer-runtime/build/avidgstmeta)

set(ENV{PKG_CONFIG_PATH}  ${PACKAGE_CONFIG_PATH})
find_package(PkgConfig REQUIRED)
find_package(OpenCV 4.2.0 REQUIRED)

# find NVDS
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(NVDS REQUIRED)

# include vpi wrapper
add_subdirectory(/home/avidbeam/dakdouky_ws/atun-gstreamer-runtime/avidvpiwrapper ${CMAKE_CURRENT_SOURCE_DIR}/build/avidvpiwrapper)

set(Common_Includes ${CMAKE_CURRENT_SOURCE_DIR}/include
/home/avidbeam/dakdouky_ws/atun-gstreamer-runtime/avidgstdspluginloader/include
    ${NVDS_INCLUDE_DIRS}
    ${PKG_cudart_INCLUDE_DIRS})

set(Common_Libs
    ${OpenCV_LIBRARIES}
    ${NVDS_LIBRARIES}
    ${PKG_cudart_LDFLAGS}
    avidgstmeta
    avidvpiwrapper
    )


file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cu)

add_library(${PROJECT_NAME} SHARED ${SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17)
set_target_properties(${PROJECT_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION})
target_include_directories(${PROJECT_NAME} PUBLIC ${Common_Includes})
target_link_libraries(${PROJECT_NAME} PUBLIC ${Common_Libs})
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX})

#set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

# target_compile_options(${PROJECT_NAME} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:
#                         -arch=sm_52                        
#                         -rdc=true;
#                        >)