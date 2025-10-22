cmake_minimum_required(VERSION 3.16)
project(obs-metal-fisheye-filter)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(OBS REQUIRED obs-studio)

# Find Metal framework
find_library(METAL_LIBRARY Metal)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(COREFOUNDATION_LIBRARY CoreFoundation)

# Include directories
include_directories(${OBS_INCLUDE_DIRS})

# Add compile definitions
add_definitions(${OBS_CFLAGS_OTHER})

# Create the plugin library
add_library(obs-metal-fisheye-filter MODULE
    obs-metal-fisheye-filter.cpp
)

# Link libraries
target_link_libraries(obs-metal-fisheye-filter
    ${OBS_LIBRARIES}
    ${METAL_LIBRARY}
    ${FOUNDATION_LIBRARY}
    ${COREFOUNDATION_LIBRARY}
)

# Set target properties
set_target_properties(obs-metal-fisheye-filter PROPERTIES
    PREFIX ""
    SUFFIX ".so"
    OUTPUT_NAME "obs-metal-fisheye-filter"
)

# Compile Metal shader
add_custom_command(
    OUTPUT equirectangular_to_fisheye.metallib
    COMMAND xcrun -sdk macosx metal -c equirectangular_to_fisheye.metal -o equirectangular_to_fisheye.air
    COMMAND xcrun -sdk macosx metallib equirectangular_to_fisheye.air -o equirectangular_to_fisheye.metallib
    DEPENDS equirectangular_to_fisheye.metal
    COMMENT "Compiling Metal shader"
)

# Add Metal library as dependency
add_dependencies(obs-metal-fisheye-filter equirectangular_to_fisheye.metallib)

# Install the plugin
install(TARGETS obs-metal-fisheye-filter
    LIBRARY DESTINATION lib/obs-plugins
)

# Install Metal library
install(FILES equirectangular_to_fisheye.metallib
    DESTINATION lib/obs-plugins
)

# Create plugin bundle structure
set(PLUGIN_BUNDLE_NAME "obs-metal-fisheye-filter.plugin")
set(PLUGIN_BUNDLE_PATH "${CMAKE_BINARY_DIR}/${PLUGIN_BUNDLE_NAME}")

# Create Info.plist
configure_file(
    ${CMAKE_SOURCE_DIR}/Info.plist.in
    ${CMAKE_BINARY_DIR}/Info.plist
    @ONLY
)

# Create plugin bundle
add_custom_command(
    OUTPUT ${PLUGIN_BUNDLE_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PLUGIN_BUNDLE_PATH}/Contents/MacOS
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PLUGIN_BUNDLE_PATH}/Contents/Resources
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:obs-metal-fisheye-filter> ${PLUGIN_BUNDLE_PATH}/Contents/MacOS/
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/equirectangular_to_fisheye.metallib ${PLUGIN_BUNDLE_PATH}/Contents/Resources/
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/Info.plist ${PLUGIN_BUNDLE_PATH}/Contents/
    DEPENDS obs-metal-fisheye-filter equirectangular_to_fisheye.metallib
    COMMENT "Creating plugin bundle"
)

add_custom_target(plugin_bundle ALL DEPENDS ${PLUGIN_BUNDLE_PATH})

# Install plugin bundle
install(DIRECTORY ${PLUGIN_BUNDLE_PATH}/
    DESTINATION lib/obs-plugins
    FILES_MATCHING PATTERN "*"
)
