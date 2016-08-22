cmake_minimum_required(VERSION 3.0.0)

set(ELE_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/../cmake" CACHE PATH "The path to the cmake directory")
list(APPEND CMAKE_MODULE_PATH ${ELE_CMAKE_DIR})

# set cmake_policies
include(ElePolicy)
ele_policy()

# project name and version should be set after cmake_policy CMP0048
project(utils VERSION "1.2.9")

include(EleCompilerSettings)

include(EleExecutableHelper)

include(EleDependencies)

add_subdirectory(libscrypt)

if (NOT EMSCRIPTEN)
	add_subdirectory(secp256k1)
endif()
