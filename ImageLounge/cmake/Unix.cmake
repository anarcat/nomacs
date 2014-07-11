# nomacs cmake file for a Unix/Linux build

if (ENABLE_PLUGINS)
	message(FATAL_ERROR "Plugin system is currently only supported on windows systems")
endif()


if(CMAKE_BUILD_TYPE STREQUAL "debug" OR CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "DEBUG")
    message(STATUS "A debug build. -DDEBUG is defined")
    add_definitions(-DDEBUG)
elseif()
    message(STATUS "A release build (non-debug). Debugging outputs are silently ignored.")
    add_definitions(-DQT_NO_DEBUG_OUTPUT)
endif()

# search for pkgConfig, needed for exvi2, libraw, and older OpenCV versions
find_package(PkgConfig)

# search for exiv2
pkg_check_modules(EXIV2  exiv2>=0.20)
message(STATUS "exiv2 version by pkg-config: ${EXIV2_VERSION}")

find_file(HAVE_EXIV2_HPP exiv2/exiv2.hpp ${EXIV2_INCLUDE_DIRS})
MARK_AS_ADVANCED(HAVE_EXIV2_HPP)
if (HAVE_EXIV2_HPP)
	message(STATUS "exiv2 contains exiv2.hpp, using it")
	add_definitions(-DHAVE_EXIV2_HPP)
else (HAVE_EXIV2_HPP)
	message(STATUS "exiv2 does not contain exiv2.hpp. Using older include set")
endif (HAVE_EXIV2_HPP)

if(NOT EXIV2_FOUND)
	message(FATAL_ERROR "exiv2 library was not found")
endif(NOT EXIV2_FOUND)

# search for opencv
unset(OpenCV_FOUND CACHE)
if(ENABLE_OPENCV)
	set(OpenCV_LIBS "")
	set(OpenCV_FOUND false)
	if(PKG_CONFIG_FOUND) # not sure: pkgconfig is needed for old linux  with old old opencv systems
		pkg_check_modules(OpenCV  opencv>=2.1.0)
		set(OpenCV_LIBS ${OpenCV_LIBRARIES})
	endif(PKG_CONFIG_FOUND)

	if(OpenCV_LIBS STREQUAL "")
		find_package(OpenCV 2.1.0 REQUIRED core imgproc)
	endif(OpenCV_LIBS STREQUAL "")

	if(NOT OpenCV_FOUND)
		message(FATAL_ERROR "OpenCV not found.") 
	else()
		add_definitions(-DWITH_OPENCV)
	endif()

	if(${OpenCV_VERSION} EQUAL "2.1.0")
		add_definitions(-DDISABLE_LANCZOS)
	endif()
endif(ENABLE_OPENCV)

# search for libraw
if(ENABLE_RAW)
	if(NOT OpenCV_FOUND)
		message(FATAL_ERROR "OpenCV is mandotory when enabling RAW. You have to enable ENABLE_OPENCV")
	endif()

	pkg_check_modules(LIBRAW  libraw>=0.12.0)
	if(NOT LIBRAW_FOUND)
		message(FATAL_ERROR "libraw not found. It's mandatory when used with ENABLE_RAW enabled") 
	else()
		add_definitions(-DWITH_LIBRAW)
	endif()
endif(ENABLE_RAW)

#search for multi-layer tiff
unset(TIFF_INCLUDE_DIR CACHE)
unset(TIFF_LIBRARY CACHE)
if(ENABLE_TIFF)
	if(NOT OpenCV_FOUND)
		message(FATAL_ERROR "OpenCV is mandotory when enabling TIFF. You have to enable ENABLE_OPENCV")
	endif()
	find_package(TIFF)
	if(TIFF_FOUND)
		SET(TIFF_CONFIG_DIR "")
		add_definitions(-DWITH_LIBTIFF)
	else()
		message(FATAL_ERROR "libtiff was not found. It's mandatory when used with ENABLE_TIFF enabled.")
	endif()
endif(ENABLE_TIFF)
