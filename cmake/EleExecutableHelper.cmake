#
# this function requires the following variables to be specified:
# ELE_VERSION
# PROJECT_NAME
# PROJECT_VERSION
# PROJECT_COPYRIGHT_YEAR
# PROJECT_VENDOR
# PROJECT_DOMAIN_SECOND
# PROJECT_DOMAIN_FIRST
# SRC_LIST
# HEADERS
#
# params:
# ICON
#

macro(ele_add_executable EXECUTABLE)
	set (extra_macro_args ${ARGN})
	set (options)
	set (one_value_args ICON)
	set (multi_value_args UI_RESOURCES WIN_RESOURCES)
	cmake_parse_arguments (ELE_ADD_EXECUTABLE "${options}" "${one_value_args}" "${multi_value_args}" "${extra_macro_args}")

	if (APPLE)

		add_executable(${EXECUTABLE} MACOSX_BUNDLE ${SRC_LIST} ${HEADERS} ${ELE_ADD_EXECUTABLE_UI_RESOURCES})
		set(PROJECT_VERSION "${ELE_VERSION}")
		set(MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")
		set(MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_NAME} ${PROJECT_VERSION}")
		set(MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")
		set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}")
		set(MACOSX_BUNDLE_COPYRIGHT "${PROJECT_COPYRIGHT_YEAR} ${PROJECT_VENDOR}")
		set(MACOSX_BUNDLE_GUI_IDENTIFIER "${PROJECT_DOMAIN_SECOND}.${PROJECT_DOMAIN_FIRST}")
		set(MACOSX_BUNDLE_BUNDLE_NAME ${EXECUTABLE})
		set(MACOSX_BUNDLE_ICON_FILE ${ELE_ADD_EXECUTABLE_ICON})
		set_target_properties(${EXECUTABLE} PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/ElementremMacOSXBundleInfo.plist.in")
		set_source_files_properties(${EXECUTABLE} PROPERTIES MACOSX_PACKAGE_LOCATION MacOS)
		set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/${MACOSX_BUNDLE_ICON_FILE}.icns" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

	else ()
		add_executable(${EXECUTABLE} ${ELE_ADD_EXECUTABLE_UI_RESOURCES}  ${ELE_ADD_EXECUTABLE_WIN_RESOURCES} ${SRC_LIST} ${HEADERS})
	endif()

endmacro()

macro(ele_simple_add_executable EXECUTABLE)
	add_executable(${EXECUTABLE} ${SRC_LIST} ${HEADERS})

	# Apple does not support statically linked binaries on OS X.   That means
	# that we can only statically link against our external libraries, but
	# we cannot statically link against the C++ runtime libraries and other
	# platform libraries (as is possible on Windows and Alpine Linux) to produce
	# an entirely transportable binary.
	#
	# See https://developer.apple.com/library/mac/qa/qa1118/_index.html for more info.
	#
	# GLIBC also appears not to support static linkage too, which probably means that
	# Debian and Ubuntu will only be able to do partially-statically linked
	# executables too, just like OS X.
	#
	# For OS X, at the time of writing, we are left with the following dynamically
	# linked dependencies, of which curl and libz might still be fixable:
	#
	# /usr/lib/libc++.1.dylib
	# /usr/lib/libSystem.B.dylib
	# /usr/lib/libcurl.4.dylib
	# /usr/lib/libz.1.dylib
	#
	if (STATIC_LINKING AND NOT APPLE)
		set(CMAKE_EXE_LINKER_FLAGS "-static ${CMAKE_EXE_LINKER_FLAGS}")
		set_target_properties(${EXECUTABLE} PROPERTIES LINK_SEARCH_START_STATIC 1)
		set_target_properties(${EXECUTABLE} PROPERTIES LINK_SEARCH_END_STATIC 1)
	endif()
endmacro()

macro(ele_copy_dll EXECUTABLE DLL)
	# dlls must be unsubstitud list variable (without ${}) in format
	# optimized;path_to_dll.dll;debug;path_to_dlld.dll
	if(DEFINED MSVC)
		list(GET ${DLL} 1 DLL_RELEASE)
		list(GET ${DLL} 3 DLL_DEBUG)
		add_custom_command(TARGET ${EXECUTABLE}
			PRE_BUILD
			COMMAND ${CMAKE_COMMAND} ARGS
			-DDLL_RELEASE="${DLL_RELEASE}"
			-DDLL_DEBUG="${DLL_DEBUG}"
			-DCONF="$<CONFIGURATION>"
			-DDESTINATION="${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}"
			-P "${ELE_SCRIPTS_DIR}/copydlls.cmake"
		)
	endif()
endmacro()

macro(ele_copy_dlls EXECUTABLE)
	foreach(dll ${ARGN})
		ele_copy_dll(${EXECUTABLE} ${dll})
	endforeach(dll)
endmacro()

#
# this function requires the following variables to be specified:
# ELE_DEPENDENCY_INSTALL_DIR
#
# params:
# QMLDIR
#

macro(ele_install_executable EXECUTABLE)

	set (extra_macro_args ${ARGN})
	set (options)
	set (one_value_args QMLDIR)
	set (multi_value_args)
	cmake_parse_arguments (ELE_INSTALL_EXECUTABLE "${options}" "${one_value_args}" "${multi_value_args}" "${extra_macro_args}")

	if (ELE_INSTALL_EXECUTABLE_QMLDIR)
		if (APPLE)
			set(ele_qml_dir "-qmldir=${ELE_INSTALL_EXECUTABLE_QMLDIR}")
		elseif (WIN32)
			set(ele_qml_dir "--qmldir ${ELE_INSTALL_EXECUTABLE_QMLDIR}")
		endif()
		message(STATUS "${EXECUTABLE} qmldir: ${ele_qml_dir}")
	endif()

	if (APPLE)
		# First have qt5 install plugins and frameworks
		add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
			COMMAND ${MACDEPLOYQT_APP} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${EXECUTABLE}.app -executable=${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${EXECUTABLE}.app/Contents/MacOS/${EXECUTABLE} ${ele_qml_dir}
			WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
			COMMAND sh ${ELE_SCRIPTS_DIR}/macdeployfix.sh ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${EXECUTABLE}.app/Contents
		)

		# This tool and next will inspect linked libraries in order to determine which dependencies are required
		if (${CMAKE_CFG_INTDIR} STREQUAL ".")
			# TODO: This should only happen for GUI application
			set(APP_BUNDLE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}.app")
		else ()
			set(APP_BUNDLE_PATH "${CMAKE_CURRENT_BINARY_DIR}/\$ENV{CONFIGURATION}/${EXECUTABLE}.app")
		endif ()

		install(CODE "
			include(BundleUtilities)
			set(BU_CHMOD_BUNDLE_ITEMS 1)
			verify_app(\"${APP_BUNDLE_PATH}\")
			" COMPONENT RUNTIME )

	elseif (DEFINED MSVC)

		# Map from CMake configurations to Qt configurations, so that we get the right DLLs deployed.
		set(WINDEPLOYQT_PARAMS "")
		if (CMAKE_BUILD_TYPE MATCHES Debug)
			set(WINDEPLOYQT_PARAMS "--debug")
		elseif(CMAKE_BUILD_TYPE MATCHES Release)
			set(WINDEPLOYQT_PARAMS "--release")
		elseif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
			set(WINDEPLOYQT_PARAMS "--release-with-debug-info")
		elseif (CMAKE_BUILD_TYPE MATCHES MinSizeRel)
			set(WINDEPLOYQT_PARAMS "--release")
		endif()

		get_target_property(TARGET_LIBS ${EXECUTABLE} INTERFACE_LINK_LIBRARIES)
		string(REGEX MATCH "Qt5::Core" HAVE_QT ${TARGET_LIBS})
		if ("${HAVE_QT}" STREQUAL "Qt5::Core")
			add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
				COMMAND cmd /C "set PATH=${Qt5Core_DIR}/../../../bin;%PATH% && ${WINDEPLOYQT_APP} ${WINDEPLOYQT_PARAMS} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${EXECUTABLE}.exe ${ele_qml_dir}"
				WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
			)
			#workaround for https://bugreports.qt.io/browse/QTBUG-42083
			add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
				COMMAND cmd /C "(echo [Paths] & echo.Prefix=.)" > "qt.conf"
				WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR} VERBATIM
			)
		endif()

		set(COMPONENT ${EXECUTABLE})
		if (${EXECUTABLE} STREQUAL "Mix-ide")
			# Special case because component names will be turned into cmake variables
			# and `-` cannot be part of a cmake variable
			set(COMPONENT Mix)
		endif()
		install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Debug/"
			DESTINATION .
			CONFIGURATIONS Debug
			COMPONENT ${COMPONENT}
		)

		install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Release/"
			DESTINATION .
			CONFIGURATIONS Release
			COMPONENT ${COMPONENT}
		)

		install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/RelWithDebInfo/"
			DESTINATION .
			CONFIGURATIONS RelWithDebInfo
			COMPONENT ${COMPONENT}
		)

	else()
		install( TARGETS ${EXECUTABLE} RUNTIME DESTINATION bin)
	endif ()

endmacro()

macro (ele_name KEY VALUE)
	if (NOT (APPLE OR WIN32))
		string(TOLOWER ${VALUE} LVALUE )
		set(${KEY} ${LVALUE})
	else()
		set(${KEY} ${VALUE})
	endif()
endmacro()

macro(ele_nsis)

	if (DEFINED MSVC)
		# packaging stuff
		include(InstallRequiredSystemLibraries)
		set(CPACK_GENERATOR "NSIS")
		set(CPACK_PACKAGE_NAME "cpp-elementrem")
		set(CPACK_PACKAGE_FILE_NAME "cpp-elementrem-windows")
		set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "cpp-elementrem")
		set(CPACK_PACKAGE_VENDOR "elementrem.org")
		set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
		set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
		set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
		set(CPACK_NSIS_DISPLAY_NAME "cpp-elementrem")
		set(CPACK_PACKAGE_INSTALL_DIRECTORY "cpp-elementrem")
		set(CPACK_NSIS_HELP_LINK "https://elementrem.org")
		set(CPACK_NSIS_URL_INFO_ABOUT "https://elementrem.org")
		set(CPACK_NSIS_CONTACT "elementrem.org")
		set(CPACK_NSIS_MODIFY_PATH OFF)
		set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/res/win/alelezero.ico")
		set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_SOURCE_DIR}/res/win/alelezero.ico")
		set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL TRUE)
		if (CMAKE_CL_64)
			set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
			set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION}")
		else ()
			set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
			set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION} (Win32)")
		endif()

		set(CPACK_COMPONENT_ALELEZERO_GROUP "Applications")
		set(CPACK_COMPONENT_MIX_GROUP "Applications")
		set(CPACK_COMPONENT_SOLC_GROUP "CLI")
		set(CPACK_COMPONENT_ELE_GROUP "CLI")
		set(CPACK_COMPONENT_ELEMINER_GROUP "CLI")
		set(CPACK_COMPONENT_ELEKEY_GROUP "CLI")
		set(CPACK_COMPONENT_RLP_GROUP "CLI")
		set(CPACK_COMPONENT_ABI_GROUP "CLI")

		# Make GUI components required as we creating links for them
		set(CPACK_COMPONENT_ALELEZERO_REQUIRED TRUE)
		set(CPACK_COMPONENT_MIX_REQUIRED TRUE)

		set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
		set(CPACK_PACKAGE_EXECUTABLES
			"AleleZero;AleleZero"
			"Mix-ide;Mix"
		)

		set(CPACK_COMPONENTS_ALL AleleZero Mix solc ele eleminer elekey)

		include(CPack)
	endif ()

endmacro()

macro(ele_appdmg)
	if (GUI AND DEFINED APPLE)
		add_custom_target(appdmg
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			COMMAND ${CMAKE_COMMAND}
			-DAPP_DMG_EXE=${ELE_APP_DMG}
			-DAPP_DMG_FILE="${CMAKE_CURRENT_SOURCE_DIR}/res/mac/appdmg.json.in"
			-DAPP_DMG_ICON="${CMAKE_CURRENT_SOURCE_DIR}/res/mac/alelezero.icns"
			-DAPP_DMG_BACKGROUND="${CMAKE_CURRENT_SOURCE_DIR}/res/mac/install-folder-bg@2x.png"
			-DELE_BUILD_DIR="${CMAKE_BINARY_DIR}"
			-DELE_ALELEZERO_APP="$<TARGET_FILE_DIR:AleleZero>"
			-DELE_MIX_APP="$<TARGET_FILE_DIR:Mix-ide>"
			-P "${ELE_SCRIPTS_DIR}/appdmg.cmake"
		)
	endif()
endmacro()

macro(jsonrpcstub_client_create SPEC CLIENTNAME CLIENTDIR CLIENTFILENAME)
	if (ELE_JSON_RPC_STUB)
		add_custom_target(${SPEC}stub)
		add_custom_command(
		TARGET ${SPEC}stub
		POST_BUILD
		DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SPEC}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMAND ${CMAKE_COMMAND} -DELE_SPEC_PATH="${CMAKE_CURRENT_SOURCE_DIR}/${SPEC}" -DELE_SOURCE_DIR="${CMAKE_SOURCE_DIR}" -DELE_CMAKE_DIR="${ELE_CMAKE_DIR}"
			-DELE_CLIENT_DIR="${CLIENTDIR}"
			-DELE_CLIENT_NAME=${CLIENTNAME}
			-DELE_CLIENT_FILENAME=${CLIENTFILENAME}
			-DELE_JSON_RPC_STUB="${ELE_JSON_RPC_STUB}"
			-P "${ELE_SCRIPTS_DIR}/jsonrpcstub.cmake"
			)
		add_dependencies(${EXECUTABLE} ${SPEC}stub)
	endif ()
endmacro()

macro(jsonrpcstub_create SPEC SERVERNAME SERVERDIR SERVERFILENAME CLIENTNAME CLIENTDIR CLIENTFILENAME)
	if (ELE_JSON_RPC_STUB)
		add_custom_target(${SPEC}stub)
		add_custom_command(
		TARGET ${SPEC}stub
		POST_BUILD
		DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SPEC}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMAND ${CMAKE_COMMAND} -DELE_SPEC_PATH="${CMAKE_CURRENT_SOURCE_DIR}/${SPEC}" -DELE_SOURCE_DIR="${CMAKE_SOURCE_DIR}" -DELE_CMAKE_DIR="${ELE_CMAKE_DIR}"
			-DELE_CLIENT_DIR="${CLIENTDIR}"
			-DELE_CLIENT_NAME=${CLIENTNAME}
			-DELE_CLIENT_FILENAME=${CLIENTFILENAME}
			-DELE_SERVER_DIR="${SERVERDIR}"
			-DELE_SERVER_NAME=${SERVERNAME}
			-DELE_SERVER_FILENAME=${SERVERFILENAME}
			-DELE_JSON_RPC_STUB="${ELE_JSON_RPC_STUB}"
			-P "${ELE_SCRIPTS_DIR}/jsonrpcstub.cmake"
			)
		add_dependencies(${EXECUTABLE} ${SPEC}stub)
	endif ()
endmacro()

