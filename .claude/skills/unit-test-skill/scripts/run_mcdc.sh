#!/usr/bin/env bash
# @brief  LLVM 소스 기반 커버리지(MC/DC 포함)로 단위 테스트를 빌드·실행·리포트한다.
# @usage  run_mcdc.sh <test.cpp> <unit_src.cpp>... [-- <추가 clang 옵션>]
# @env    CXX (기본 clang++), COV_DIR (기본 build/cov), TEST_LIBS (기본: GTest/GMock)
# @return 0 성공 / 그 외 빌드·테스트 실패
set -euo pipefail

CC="${CXX:-clang++}"
COV_DIR="${COV_DIR:-build/cov}"
SRCS=()
EXTRA=()
while [ $# -gt 0 ]; do
  if [ "$1" = "--" ]; then shift; EXTRA=("$@"); break; fi
  SRCS+=("$1"); shift
done
[ ${#SRCS[@]} -ge 2 ] || { echo "usage: $0 <test.cpp> <unit.cpp>... [-- opts]" >&2; exit 2; }

mkdir -p "$COV_DIR"
BIN="$COV_DIR/unit_test"

# MC/DC: clang 18+. 최적화 끄고 디버그 정보 유지.
"$CC" -O0 -g -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc \
      "${SRCS[@]}" ${TEST_LIBS:--lgmock -lgtest -lgtest_main -pthread} "${EXTRA[@]}" -o "$BIN"

LLVM_PROFILE_FILE="$COV_DIR/unit.profraw" "$BIN"

llvm-profdata merge -sparse "$COV_DIR/unit.profraw" -o "$COV_DIR/unit.profdata"

# 테스트 코드(첫 번째 소스)는 측정 대상에서 제외
llvm-cov report "$BIN" -instr-profile="$COV_DIR/unit.profdata" \
         --ignore-filename-regex='(^|/)test/' | tee "$COV_DIR/summary.txt"
llvm-cov show "$BIN" -instr-profile="$COV_DIR/unit.profdata" \
         --show-mcdc --show-branches=count --ignore-filename-regex='(^|/)test/' \
         > "$COV_DIR/mcdc.txt"
llvm-cov show "$BIN" -instr-profile="$COV_DIR/unit.profdata" \
         --format=html --show-mcdc -output-dir="$COV_DIR/html" \
         --ignore-filename-regex='(^|/)test/'
echo "report: $COV_DIR/mcdc.txt, $COV_DIR/html/index.html"
