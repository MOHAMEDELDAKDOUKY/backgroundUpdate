# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build

# Include any dependencies generated for this target.
include avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/depend.make

# Include the progress variables for this target.
include avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/progress.make

# Include the compile flags for this target's objects.
include avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/flags.make

avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o: avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/flags.make
avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o: /media/avidbeam/workspace/Nadia-Ws/atun-gstreamer-runtime/avidvpiwrapper/avidvpiwrapper.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o"
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o -c /media/avidbeam/workspace/Nadia-Ws/atun-gstreamer-runtime/avidvpiwrapper/avidvpiwrapper.cpp

avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.i"
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /media/avidbeam/workspace/Nadia-Ws/atun-gstreamer-runtime/avidvpiwrapper/avidvpiwrapper.cpp > CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.i

avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.s"
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /media/avidbeam/workspace/Nadia-Ws/atun-gstreamer-runtime/avidvpiwrapper/avidvpiwrapper.cpp -o CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.s

# Object files for target avidvpiwrapper
avidvpiwrapper_OBJECTS = \
"CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o"

# External object files for target avidvpiwrapper
avidvpiwrapper_EXTERNAL_OBJECTS =

avidvpiwrapper/libavidvpiwrapper.so: avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/avidvpiwrapper.cpp.o
avidvpiwrapper/libavidvpiwrapper.so: avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/build.make
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvbufsurface.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvbufsurftransform.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvdsgst_helper.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvdsgst_meta.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvds_meta.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/deepstream/deepstream/lib/libnvds_infer.so
avidvpiwrapper/libavidvpiwrapper.so: /opt/nvidia/vpi1/lib64/libnvvpi.so.1.2.3
avidvpiwrapper/libavidvpiwrapper.so: avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX shared library libavidvpiwrapper.so"
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/avidvpiwrapper.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/build: avidvpiwrapper/libavidvpiwrapper.so

.PHONY : avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/build

avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/clean:
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper && $(CMAKE_COMMAND) -P CMakeFiles/avidvpiwrapper.dir/cmake_clean.cmake
.PHONY : avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/clean

avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/depend:
	cd /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate /media/avidbeam/workspace/Nadia-Ws/atun-gstreamer-runtime/avidvpiwrapper /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper /media/avidbeam/workspace/dakdouky_ws/left_object_detection/backgroundUpdate/build/avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : avidvpiwrapper/CMakeFiles/avidvpiwrapper.dir/depend

