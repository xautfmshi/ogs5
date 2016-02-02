#
# Benchmark
# -------
#
# Creates a benchmark test run. Order of arguments can be arbitrary.
#
# Benchmark(
#   AUTHOR <short name of the responsible benchmark author>
#   PATH <working directory> # relative to bencharks-directory
#   CONFIG <ogs configuration> # defaults to FEM
#   REQUIRED_CMAKE_OPTIONS <cmake options> # optional
#   OUTPUT_FILES <files> # output files which should be compared to references
#   RUNTIME <seconds> # the average runtime of this benchmarks in seconds
# )
#

function(Benchmark)

	# parse arguments
	set(options NONE)
	set(oneValueArgs AUTHOR PATH NUM_PROCESSORS TIMEOUT CONFIG)
	set(multiValueArgs REQUIRED_CMAKE_OPTIONS OUTPUT_FILES)
	cmake_parse_arguments(Benchmark "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	# set defaults
	if(NOT Benchmark_CONFIG)
		set(Benchmark_CONFIG FEM)
	endif()
	if(NOT Benchmark_NUM_PROCESSORS)
		set(Benchmark_NUM_PROCESSORS 1)
	endif()
	if(NOT Benchmark_TIMEOUT)
		set(Benchmark_TIMEOUT ${BENCHMARK_TIMEOUT})
	endif()

	# Check required CMake configuration
	if(NOT Benchmark_CONFIG STREQUAL OGS_CONFIG)
		return()
	endif()
	foreach(REQUIRED_CMAKE_OPTION ${Benchmark_REQUIRED_CMAKE_OPTIONS})
		if(NOT ${REQUIRED_CMAKE_OPTION})
			return()
			# message("Disabling benchmark ${Benchmark_NAME} because ${REQUIRED_CMAKE_OPTION} = ${${REQUIRED_CMAKE_OPTION}}")
		endif()
	endforeach()

	string (REGEX MATCH "[^/]+$" benchmarkStrippedName ${Benchmark_PATH})
	string (LENGTH ${Benchmark_PATH} benchmarkNameLength)
	string (LENGTH ${benchmarkStrippedName} benchmarkStrippedNameLength)
	math (EXPR substringLength ${benchmarkNameLength}-${benchmarkStrippedNameLength})
	string (SUBSTRING ${Benchmark_PATH} 0 ${substringLength} benchmarkDir)
	string (REPLACE "/" "_" benchmarkNameUnderscore ${Benchmark_PATH})
	string (REPLACE "_LONG_" "_" benchmarkNameUnderscore ${benchmarkNameUnderscore})
	string (REPLACE "_EXCEEDING_" "_" benchmarkNameUnderscore ${benchmarkNameUnderscore})

	# Adds a benchmark run. This calls AddTest.cmake to execute several steps.
	add_test(
		${Benchmark_AUTHOR}-${Benchmark_PATH}
		${CMAKE_COMMAND}
		-DPROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}
		-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}
		-DEXECUTABLE_OUTPUT_PATH=${EXECUTABLE_OUTPUT_PATH}
		-DbenchmarkStrippedName=${benchmarkStrippedName}
		-DbenchmarkDir=${benchmarkDir}
		-DOGS_PROFILE=${OGS_PROFILE}
		-DOGS_OUTPUT_PROFILE=${OGS_OUTPUT_PROFILE}
		-DGPROF_PATH=${GPROF_PATH}
		-DDOT_TOOL_PATH=${DOT_TOOL_PATH}
		-DNUM_PROCESSES=${Benchmark_NUM_PROCESSORS}
		-DOUTPUT_FILES=${Benchmark_OUTPUT_FILES}
		-P ${PROJECT_SOURCE_DIR}/scripts/cmake/AddBenchmark.cmake
	)
	set_tests_properties(${Benchmark_AUTHOR}-${Benchmark_PATH} PROPERTIES
		PROCESSORS ${Benchmark_NUM_PROCESSORS}
		TIMEOUT ${Benchmark_TIMEOUT}
	)

	# compare file differences with python script
	#if(PYTHONINTERP_FOUND)
	#	file (REMOVE ${PROJECT_SOURCE_DIR}/../benchmarks/results/temp/temp_${benchmarkNameUnderscore}.txt)
	#	foreach (entry ${OUTPUT_FILES})
	#		file (APPEND ${PROJECT_SOURCE_DIR}/../benchmarks/results/temp/temp_${benchmarkNameUnderscore}.txt "${entry}\n")
	#	endforeach ()
	#	add_test(
	#		${Benchmark_AUTHORS}_FILECOMPARE_${Benchmark_PATH}
	#		${CMAKE_COMMAND} -E chdir ${PROJECT_SOURCE_DIR}/../benchmarks/results
	#		${PYTHON_EXECUTABLE}
	#		${PROJECT_SOURCE_DIR}/scripts/compare.py
	#		temp/temp_${benchmarkNameUnderscore}.txt
	#		../../benchmarks_ref/
	#		${Benchmark_AUTHORS}_${benchmarkNameUnderscore}.html
	#		../
	#	)
	#	set_tests_properties(${Benchmark_AUTHORS}_FILECOMPARE_${Benchmark_PATH} PROPERTIES
	#		DEPENDS ${Benchmark_AUTHORS}_BENCHMARK_${Benchmark_PATH})
	#endif()



endfunction()
