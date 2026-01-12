# CMakeLists.txt for ft_mobile_agent_flutter Windows plugin
# This links to ft-sdk as a DLL instead of including source code

cmake_minimum_required(VERSION 3.14)

# ============ vcpkg toolchain file ============
# Set vcpkg toolchain file if not already set
# This must be done before project() command
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
  endif()
  if(DEFINED VCPKG_TOOLCHAIN_FILE AND EXISTS "${VCPKG_TOOLCHAIN_FILE}")
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_TOOLCHAIN_FILE}" CACHE STRING "vcpkg toolchain file")
    message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")
  else()
    message(WARNING "vcpkg toolchain file not found. Set CMAKE_TOOLCHAIN_FILE or VCPKG_ROOT.")
  endif()
endif()

# Project definition
set(PROJECT_NAME "ft_mobile_agent_flutter_plugin")
project(${PROJECT_NAME} LANGUAGES CXX)

# Flutter builds the INSTALL target; avoid writing to system locations.
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Install prefix" FORCE)
endif()

# C++20 standard required (stduuid needs std::span)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Note: FTSDK_STATIC_DEFINE is NOT defined here, so we use DLL import/export

# Disable some warnings that appear in third-party code
if(MSVC)
  add_compile_options(/wd4267 /wd4244 /wd4996)
endif()

# ============ vcpkg dependencies ============
# These packages should be installed via vcpkg
# Note: Plugin code needs these headers at compile time

# Get real path to handle symlinks (Flutter creates symlinks for plugins)
get_filename_component(REAL_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" REALPATH)
set(VCPKG_INSTALLED_DIR "${REAL_SOURCE_DIR}/vcpkg_installed")
if(NOT EXISTS "${VCPKG_INSTALLED_DIR}" AND DEFINED ENV{VCPKG_ROOT})
  set(VCPKG_INSTALLED_DIR "$ENV{VCPKG_ROOT}/installed")
endif()
if(VCPKG_INSTALLED_DIR)
  file(TO_CMAKE_PATH "${VCPKG_INSTALLED_DIR}" VCPKG_INSTALLED_DIR)
endif()

# Add vcpkg installed directory to CMAKE_PREFIX_PATH if it exists
# VCPKG_TARGET_TRIPLET is set by vcpkg toolchain file after project() call
if(EXISTS "${VCPKG_INSTALLED_DIR}" AND DEFINED VCPKG_TARGET_TRIPLET)
  list(APPEND CMAKE_PREFIX_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
  message(STATUS "Added vcpkg installed directory to CMAKE_PREFIX_PATH: ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
elseif(EXISTS "${VCPKG_INSTALLED_DIR}")
  # Fallback: try common triplet names
  foreach(TRIPLET "x64-windows" "x86-windows")
    if(EXISTS "${VCPKG_INSTALLED_DIR}/${TRIPLET}")
      list(APPEND CMAKE_PREFIX_PATH "${VCPKG_INSTALLED_DIR}/${TRIPLET}")
      message(STATUS "Added vcpkg installed directory to CMAKE_PREFIX_PATH: ${VCPKG_INSTALLED_DIR}/${TRIPLET}")
      break()
    endif()
  endforeach()
endif()

find_package(CURL CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(SQLiteCpp CONFIG REQUIRED)

# restclient-cpp may have different package names depending on vcpkg version
find_package(restclient-cpp CONFIG QUIET)
if(NOT restclient-cpp_FOUND)
  find_package(unofficial-restclient-cpp CONFIG QUIET)
endif()

# stduuid is header-only, just need to find the include path
find_path(STDUUID_INCLUDE_DIRS "uuid.h" PATH_SUFFIXES stduuid)

# ============ Build ft-sdk from source ============
# Fetch ft-sdk-cpp source from remote zip (or override with a local path).
#set(FTSDK_CPP_SDK_VERSION "local" CACHE STRING "ft-sdk-cpp version")

set(FTSDK_CPP_SDK_VERSION "1.0.0")

set(FTSDK_CPP_SDK_URL "https://codeload.github.com/GuanceCloud/datakit-cpp/zip/refs/heads/feature_flutter_windows"
  CACHE STRING "ft-sdk-cpp source ZIP URL")
set(FTSDK_CPP_SDK_DIR "" CACHE PATH "Optional local ft-sdk-cpp source directory")
option(FTSDK_USE_VCPKG_THIRD_PARTY "Bundle runtime DLLs from vcpkg targets" ON)

if(FTSDK_CPP_SDK_DIR)
  set(_ft_sdk_cpp_root "${FTSDK_CPP_SDK_DIR}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ft-sdk-cpp")
  set(_ft_sdk_cpp_root "${CMAKE_CURRENT_SOURCE_DIR}/ft-sdk-cpp")
elseif(DEFINED ENV{FTSDK_CPP_SDK_DIR})
  set(_ft_sdk_cpp_root "$ENV{FTSDK_CPP_SDK_DIR}")
else()
  set(_ft_sdk_cpp_zip "${CMAKE_BINARY_DIR}/ft-sdk-cpp.zip")
  set(_ft_sdk_cpp_extract "${CMAKE_BINARY_DIR}/ft-sdk-cpp")
  if(NOT EXISTS "${_ft_sdk_cpp_zip}")
    file(DOWNLOAD "${FTSDK_CPP_SDK_URL}" "${_ft_sdk_cpp_zip}"
      SHOW_PROGRESS
      STATUS _ft_sdk_download_status
      LOG _ft_sdk_download_log)
    list(GET _ft_sdk_download_status 0 _ft_sdk_status_code)
    if(NOT _ft_sdk_status_code EQUAL 0)
      message(FATAL_ERROR "ft-sdk-cpp download failed: ${_ft_sdk_download_log}")
    endif()
  else()
    message(STATUS "Using cached ft-sdk-cpp zip: ${_ft_sdk_cpp_zip}")
  endif()

  if(NOT EXISTS "${_ft_sdk_cpp_extract}")
    file(MAKE_DIRECTORY "${_ft_sdk_cpp_extract}")
    file(ARCHIVE_EXTRACT INPUT "${_ft_sdk_cpp_zip}" DESTINATION "${_ft_sdk_cpp_extract}")
  else()
    message(STATUS "Using cached extracted ft-sdk-cpp: ${_ft_sdk_cpp_extract}")
  endif()

  file(GLOB _ft_sdk_cpp_dirs LIST_DIRECTORIES true "${_ft_sdk_cpp_extract}/*")
  list(GET _ft_sdk_cpp_dirs 0 _ft_sdk_cpp_root)
endif()

if(EXISTS "${_ft_sdk_cpp_root}/src/datakit-sdk-cpp/ft-sdk/CMakeLists.txt")
  set(FTSDK_SOURCE_ROOT "${_ft_sdk_cpp_root}/src/datakit-sdk-cpp/ft-sdk")
elseif(EXISTS "${_ft_sdk_cpp_root}/datakit-sdk-cpp/ft-sdk/CMakeLists.txt")
  set(FTSDK_SOURCE_ROOT "${_ft_sdk_cpp_root}/datakit-sdk-cpp/ft-sdk")
else()
  message(FATAL_ERROR "ft-sdk source not found under ${_ft_sdk_cpp_root}")
endif()

add_subdirectory("${FTSDK_SOURCE_ROOT}" "${CMAKE_CURRENT_BINARY_DIR}/ft-sdk")

# Silence noisy third-party warnings from ft-sdk sources.
if(MSVC AND TARGET ft-sdk)
  target_compile_options(ft-sdk PRIVATE
    /wd4200  # zero-sized array in struct/union
    /wd4273  # inconsistent dll linkage
    /wd4715  # not all control paths return a value
    /wd4018  # signed/unsigned mismatch
  )
endif()


# ============ Plugin source files ============
set(PLUGIN_SOURCES
  ft_mobile_agent_flutter_plugin.cpp
  ft_mobile_agent_flutter_plugin.h
  method_channel_handler.cpp
  method_channel_handler.h
  data_converter.cpp
  data_converter.h
  ft_sdk_adapter.cpp
  ft_sdk_adapter.h
)

# ============ Include directories ============
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/include         # For public plugin headers
  ${STDUUID_INCLUDE_DIRS}
  ${FTSDK_SOURCE_ROOT}          # For ft-sdk root (needed for "Include/xxx.h" relative paths)
  ${FTSDK_SOURCE_ROOT}/Include  # For ft-sdk public headers
  ${FTSDK_SOURCE_ROOT}          # For ft-sdk internal headers (ft-sdk-cpp layout)
)

# ============ Create plugin shared library ============
add_library(${PROJECT_NAME} SHARED
  ${PLUGIN_SOURCES}
)

# ============ Link dependencies ============
target_link_libraries(${PROJECT_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  ft-sdk  # Link to ft-sdk DLL
  version.lib  # For GetFileVersionInfo* functions
)

# Plugin code needs fmt and SQLiteCpp headers at compile time
# Add their include directories to the plugin target
if(TARGET fmt::fmt)
  target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)
endif()

if(TARGET SQLiteCpp)
  target_link_libraries(${PROJECT_NAME} PRIVATE SQLiteCpp)
endif()

# Note: restclient-cpp and other dependencies are linked by ft-sdk DLL
# No need to link them here again

# ============ Flutter plugin standard settings ============
apply_standard_settings(${PROJECT_NAME})

set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
)

target_compile_definitions(${PROJECT_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Windows-specific settings
target_compile_definitions(${PROJECT_NAME} PRIVATE
  WIN32_LEAN_AND_MEAN
  NOMINMAX
)

# Silence third-party warnings surfaced through public headers.
if(MSVC)
  target_compile_options(${PROJECT_NAME} PRIVATE
    /wd4275  # non-dll interface class used as base for dll interface class
    /wd4251  # dll interface needed for STL member
    /wd4005  # macro redefinition
    /wd4458  # declaration hides class member
    /wd4189  # local variable initialized but not referenced
  )
endif()

# Set public include directory for the plugin
target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Set the plugin's public header file
set_target_properties(${PROJECT_NAME} PROPERTIES
  PUBLIC_HEADER "include/ft_mobile_agent_flutter/ft_mobile_agent_flutter_plugin.h"
)

# Ensure ft-sdk DLL is copied to the same directory as the plugin DLL
# This is important for runtime loading
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E echo "ft-sdk.dll source: $<TARGET_FILE:ft-sdk>"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:ft-sdk>
    $<TARGET_FILE_DIR:${PROJECT_NAME}>
  COMMENT "Copying ft-sdk.dll to plugin output directory"
)

# Register ft-sdk.dll as aed library for Flutter installation
# This ensures it gets copied to the executable directory when Flutter installs plugins
# Flutter's generated_plugins.cmake will read this variable and include ft-sdk.dll in PLUGIN_BUNDLED_LIBRARIES
# Note: We need to use a generator expression, but set it as a list to ensure proper handling
set(ft_mobile_agent_flutter_bundled_libraries
  $<TARGET_FILE:ft-sdk>
)

# Bundle ft-sdk runtime deps so the app can run without manual DLL copies.
if(FTSDK_USE_VCPKG_THIRD_PARTY)
  list(APPEND ft_mobile_agent_flutter_bundled_libraries
    $<$<TARGET_EXISTS:fmt::fmt>:$<TARGET_FILE:fmt::fmt>>
    $<$<TARGET_EXISTS:spdlog::spdlog>:$<TARGET_FILE:spdlog::spdlog>>
    $<$<TARGET_EXISTS:SQLiteCpp>:$<TARGET_FILE:SQLiteCpp>>
    $<$<TARGET_EXISTS:unofficial::sqlite3::sqlite3>:$<TARGET_FILE:unofficial::sqlite3::sqlite3>>
    $<$<TARGET_EXISTS:CURL::libcurl>:$<TARGET_FILE:CURL::libcurl>>
    $<$<TARGET_EXISTS:ZLIB::ZLIB>:$<TARGET_FILE:ZLIB::ZLIB>>
  )

  # Fallback: explicitly bundle DLLs from vcpkg bin folders.
  if(DEFINED VCPKG_TARGET_TRIPLET AND EXISTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    set(_vcpkg_triplet "${VCPKG_TARGET_TRIPLET}")
  else()
    foreach(_triplet "x64-windows" "x86-windows")
      if(EXISTS "${VCPKG_INSTALLED_DIR}/${_triplet}")
        set(_vcpkg_triplet "${_triplet}")
        break()
      endif()
    endforeach()
  endif()

  if(DEFINED _vcpkg_triplet)
    set(_vcpkg_bin "${VCPKG_INSTALLED_DIR}/${_vcpkg_triplet}/bin")
    set(_vcpkg_debug_bin "${VCPKG_INSTALLED_DIR}/${_vcpkg_triplet}/debug/bin")
    if(EXISTS "${_vcpkg_bin}")
      list(APPEND ft_mobile_agent_flutter_bundled_libraries
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/fmt.dll>
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/spdlog.dll>
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/libcurl.dll>
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/sqlite3.dll>
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/SQLiteCpp.dll>
        $<$<NOT:$<CONFIG:Debug>>:${_vcpkg_bin}/zlib1.dll>
      )
    endif()
    if(EXISTS "${_vcpkg_debug_bin}")
      list(APPEND ft_mobile_agent_flutter_bundled_libraries
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/fmtd.dll>
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/spdlogd.dll>
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/libcurl-d.dll>
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/sqlite3.dll>
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/SQLiteCpp.dll>
        $<$<CONFIG:Debug>:${_vcpkg_debug_bin}/zlibd1.dll>
      )
    endif()
  endif()
endif()

set(ft_mobile_agent_flutter_bundled_libraries
  ${ft_mobile_agent_flutter_bundled_libraries}
  PARENT_SCOPE
)


