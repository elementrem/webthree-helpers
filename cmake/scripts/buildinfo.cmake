# generates BuildInfo.h
# 
# this module expects
# ELE_SOURCE_DIR - main CMAKE_SOURCE_DIR
# ELE_DST_DIR - main CMAKE_BINARY_DIR
# ELE_BUILD_TYPE
# ELE_BUILD_PLATFORM
# ELE_BUILD_NUMBER
# ELE_VERSION_SUFFIX
#
# example usage:
# cmake -DELE_SOURCE_DIR=. -DELE_DST_DIR=build -DELE_BUILD_TYPE=Debug -DELE_BUILD_PLATFORM=mac -DELE_BUILD_NUMBER=45 -DELE_VERSION_SUFFIX="-rc1" -P scripts/buildinfo.cmake

if (NOT ELE_BUILD_TYPE)
	set(ELE_BUILD_TYPE "unknown")
endif()

if (NOT ELE_BUILD_PLATFORM)
	set(ELE_BUILD_PLATFORM "unknown")
endif()

execute_process(
	COMMAND git --git-dir=${ELE_SOURCE_DIR}/.git --work-tree=${ELE_SOURCE_DIR} rev-parse HEAD
	OUTPUT_VARIABLE ELE_COMMIT_HASH OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET
) 

if (NOT ELE_COMMIT_HASH)
	set(ELE_COMMIT_HASH 0)
endif()

execute_process(
	COMMAND git --git-dir=${ELE_SOURCE_DIR}/.git --work-tree=${ELE_SOURCE_DIR} diff HEAD --shortstat
	OUTPUT_VARIABLE ELE_LOCAL_CHANGES OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET
)

if (ELE_LOCAL_CHANGES)
	set(ELE_CLEAN_REPO 0)
else()
	set(ELE_CLEAN_REPO 1)
endif()

set(TMPFILE "${ELE_DST_DIR}/BuildInfo.h.tmp")
set(OUTFILE "${ELE_DST_DIR}/BuildInfo.h")

configure_file("${ELE_BUILDINFO_IN}" "${TMPFILE}")

include("${ELE_CMAKE_DIR}/EleUtils.cmake")
replace_if_different("${TMPFILE}" "${OUTFILE}" CREATE)

