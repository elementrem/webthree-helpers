# Find Web3
#
# Find the elementrem includes and library
#
# This module defines
#  Web3_XXX_LIBRARIES, the libraries needed to use elementrem.
#  TODO: Web3_INCLUDE_DIRS

include(EleUtils)
set(LIBS whisper;webthree;web3jsonrpc)

set(Web3_INCLUDE_DIRS ${WEB3_DIR})

# if the project is a subset of cpp-elementrem
# use same pattern for variables as Boost uses
if ((DEFINED webthree_VERSION) OR (DEFINED cpp-elementrem_VERSION))

	foreach (l ${LIBS})
		string(TOUPPER ${l} L)
		set ("Web3_${L}_LIBRARIES" ${l})
	endforeach()

else()

	foreach (l ${LIBS})
		string(TOUPPER ${l} L)

		find_library(Web3_${L}_LIBRARY
			NAMES ${l}
			PATHS ${CMAKE_LIBRARY_PATH}
			PATH_SUFFIXES "lib${l}" "${l}" "lib${l}/Release"
			NO_DEFAULT_PATH
		)

		set(Web3_${L}_LIBRARIES ${Web3_${L}_LIBRARY})

		if (DEFINED MSVC)
			find_library(Web3_${L}_LIBRARY_DEBUG
				NAMES ${l}
				PATHS ${CMAKE_LIBRARY_PATH}
				PATH_SUFFIXES "lib${l}/Debug" 
				NO_DEFAULT_PATH
			)
			ele_check_library_link(Web3_${L})
		endif()
	endforeach()

endif()
