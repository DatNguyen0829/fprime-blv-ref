# This CMake file is intended to register project-wide objects.
# This allows for reuse between deployments, or other projects.

add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/project/config")
add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/Components")

# ReferenceDeployment is specifically for Zephyr.
if (COMMAND register_fprime_zephyr_deployment)
    add_fprime_subdirectory(
        "${CMAKE_CURRENT_LIST_DIR}/ReferenceDeployment/"
    )
endif()
