set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "OGS-5")
set(CPACK_PACKAGE_VENDOR "OpenGeoSys Community (http://www.opengeosys.org)")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "OGS-${OGS_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")

if(APPLE)
	string(REGEX MATCH "(^[0-9]*)" TMP ${CMAKE_SYSTEM_VERSION})
	math(EXPR OSX_VERSION_MINOR "${CMAKE_MATCH_1} - 4")
	set(CPACK_PACKAGE_FILE_NAME
		"ogs-${OGS_VERSION}-OSX-10.${OSX_VERSION_MINOR}-x${BITS}")
	set(CPACK_SOURCE_PACKAGE_FILE_NAME ${CPACK_PACKAGE_FILE_NAME})
else()
	set(CPACK_PACKAGE_FILE_NAME "ogs-${OGS_VERSION}-${CMAKE_SYSTEM}-x${BITS}")
endif()

if(WIN32)
    include(InstallRequiredSystemLibraries)
    set(CPACK_GENERATOR ZIP)
endif()
if(UNIX)
    set(CPACK_GENERATOR TGZ)
    # Adds the binaries location to the LD_LIBRARY_PATH
    set(CMAKE_INSTALL_RPATH \$ORIGIN/)
endif()
if(APPLE)
    set(CPACK_GENERATOR TGZ)
endif()

include (CPack)
