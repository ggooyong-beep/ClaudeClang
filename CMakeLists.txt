cmake_minimum_required(VERSION 3.20)
project(ClaudeClang CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_compile_options(-Wall -Wextra -Werror)

# LLVM 소스 기반 커버리지 (MC/DC 포함). 단위/통합/TDD 테스트 측정에 사용.
option(COVERAGE "Enable LLVM coverage incl. MC/DC" OFF)
if(COVERAGE)
  add_compile_options(-O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc)
  add_link_options(-fprofile-instr-generate)
endif()

find_package(GTest REQUIRED)
file(GLOB_RECURSE CORE_SOURCES CONFIGURE_DEPENDS ${CMAKE_SOURCE_DIR}/src/*.cpp)

if(CORE_SOURCES)
  add_library(core STATIC ${CORE_SOURCES})
  target_include_directories(core PUBLIC ${CMAKE_SOURCE_DIR}/include)
endif()

# 테스트 종류별 별도 실행 파일: tdd(TDD 산출물) / unit / integration
foreach(kind tdd unit integration)
  file(GLOB_RECURSE kind_tests CONFIGURE_DEPENDS ${CMAKE_SOURCE_DIR}/test/${kind}/*.cpp)
  if(kind_tests AND CORE_SOURCES)
    add_executable(${kind}_tests ${kind_tests})
    target_link_libraries(${kind}_tests PRIVATE core GTest::gmock GTest::gtest GTest::gtest_main)
  endif()
endforeach()
