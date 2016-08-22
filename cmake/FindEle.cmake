# Find Ele
#
# Find the elementrem includes and library
#
# This module defines
#  ELE_XXX_LIBRARIES, the libraries needed to use elementrem.
#  ELE_FOUND, If false, do not try to use elementrem.
#  TODO: ELE_INCLUDE_DIRS

include(EleUtils)
set(LIBS elhashseal;elementrem;evm;elecore;evmcore;elhash-cl;elhash;natspec;evmjit;testutils)

set(Ele_INCLUDE_DIRS "${ELE_DIR}")

# if the project is a subset of main cpp-elementrem project
# use same pattern for variables as Boost uses
if ((DEFINED cpp-elementrem_VERSION) OR (DEFINED elementrem_VERSION))

	foreach (l ${LIBS})
		string(TOUPPER ${l} L)
		set ("Ele_${L}_LIBRARIES" ${l})
	endforeach()

else()

	foreach (l ${LIBS})
		string(TOUPPER ${l} L)

		find_library(Ele_${L}_LIBRARY
			NAMES ${l}
			PATHS ${CMAKE_LIBRARY_PATH}
			PATH_SUFFIXES "lib${l}" "${l}" "lib${l}/Debug" "lib${l}/Release"
			# libevmjit is nested...
			"evmjit/libevmjit" "evmjit/libevmjit/Release"
			NO_DEFAULT_PATH
		)

		set(Ele_${L}_LIBRARIES ${Ele_${L}_LIBRARY})

		if (DEFINED MSVC)
			find_library(Ele_${L}_LIBRARY_DEBUG
				NAMES ${l}
				PATHS ${CMAKE_LIBRARY_PATH}
				PATH_SUFFIXES "lib${l}/Debug"
				# libevmjit is nested...
				"evmjit/libevmjit/Debug"
				NO_DEFAULT_PATH
			)
			ele_check_library_link(Ele_${L})
		endif()
	endforeach()

endif()
