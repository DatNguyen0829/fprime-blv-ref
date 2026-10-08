cmake_minimum_required(VERSION 3.24.2)

# Allow Zephyr to discover custom board definitions under this project.
list(APPEND BOARD_ROOT "${CMAKE_CURRENT_LIST_DIR}")

# Load Zephyr for embedded builds, but not for host-based unit tests.
if (NOT BUILD_TESTING)
    find_package(
        Zephyr
        HINTS "${CMAKE_CURRENT_LIST_DIR}/lib/zephyr-workspace"
    )
endif()

project(FprimeBlvRef C CXX)

###
# F' Core Setup
# This includes all of the F prime core components, and imports the make-system.
###
include("${CMAKE_CURRENT_LIST_DIR}/lib/fprime/cmake/FPrime.cmake")

# NOTE: register custom targets between these two lines
fprime_setup_included_code()

# This includes project-wide objects
add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/FprimeBlvRef")