# Generate a QT resource file including given list of resources
# Example:
# cmake -DELE_RES_FILES=a.png;b.js -DELE_QRC_DEST=resources.qrc -P genqrc.cmake
#

file(WRITE ${ELE_QRC_DEST} "<RCC>\n<qresource prefix=\"/\">\n")
string(REPLACE " " ";" RES_LIST ${ELE_RES_FILES})
foreach(resource ${RES_LIST})
	get_filename_component(fname ${resource} NAME)
	file(APPEND ${ELE_QRC_DEST} "<file alias=\"${fname}\">${resource}</file>\n")
endforeach(resource)
file(APPEND ${ELE_QRC_DEST} "</qresource>\n</RCC>\n")

