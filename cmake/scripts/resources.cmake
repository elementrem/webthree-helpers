# based on: http://stackoverflow.com/questions/11813271/embed-resources-eg-shader-code-images-into-executable-library-with-cmake
#
# example:
# cmake -DELE_RES_FILE=test.cmake -P resources.cmake
#
# where test.cmake is:
# 
# # BEGIN OF cmake.test
# 
# set(copydlls "copydlls.cmake")
# set(conf "configure.cmake")
# 
# # this three properties must be set!
#
# set(ELE_RESOURCE_NAME "EleResources")
# set(ELE_RESOURCE_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}")
# set(ELE_RESOURCES "copydlls" "conf")
#
# # END of cmake.test
#

# should define ELE_RESOURCES
include(${ELE_RES_FILE})

set(ELE_RESULT_DATA "")
set(ELE_RESULT_INIT "")

# resource is a name visible for cpp application 
foreach(resource ${ELE_RESOURCES})

	# filename is the name of file which will be used in app
	set(filename ${${resource}})

	# filedata is a file content
	file(READ ${filename} filedata HEX)

	# read full name of the file
	file(GLOB filename ${filename})

	# Convert hex data for C compatibility
	string(REGEX REPLACE "([0-9a-f][0-9a-f])" "0x\\1," filedata ${filedata})

	# append static variables to result variable
	set(ELE_RESULT_DATA "${ELE_RESULT_DATA}	static const unsigned char ele_${resource}[] = {\n	// ${filename}\n	${filedata}\n};\n")

	# append init resources
	set(ELE_RESULT_INIT "${ELE_RESULT_INIT}	m_resources[\"${resource}\"] = (char const*)ele_${resource};\n")
	set(ELE_RESULT_INIT "${ELE_RESULT_INIT}	m_sizes[\"${resource}\"]     = sizeof(ele_${resource});\n")

endforeach(resource)

set(ELE_DST_NAME "${ELE_RESOURCE_LOCATION}/${ELE_RESOURCE_NAME}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/resource.hpp.in" "${ELE_DST_NAME}.hpp.tmp")

include("${CMAKE_CURRENT_LIST_DIR}/../EleUtils.cmake")
replace_if_different("${ELE_DST_NAME}.hpp.tmp" "${ELE_DST_NAME}.hpp")
