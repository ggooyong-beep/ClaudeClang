#!/usr/bin/env bash
# @brief 테스트 종류별 실행 + 커버리지 리포트 + 게이트 검사.
# @usage run_tests.sh <tdd|unit|integration>
#   unit        : 성공률 100% + MC/DC 100%
#   integration : 성공률 100% + 함수 커버리지 100%
#   tdd         : 별도 결과/커버리지 측정만 (게이트 없음)
set -euo pipefail
kind="${1:?usage: run_tests.sh <tdd|unit|integration>}"
bin="build/${kind}_tests"
out="build/reports/${kind}"
mkdir -p "$out"

if [ ! -x "$bin" ]; then
  echo "[$kind] 테스트가 없어 건너뜀 ($bin 없음)"
  # 빈 JUnit 파일을 남겨 CI 리포트 단계가 실패하지 않게 한다.
  echo "<testsuites/>" > "$out/junit.xml"
  exit 0
fi

LLVM_PROFILE_FILE="$out/${kind}.profraw" "$bin" --gtest_output="xml:$out/junit.xml"
llvm-profdata merge -sparse "$out/${kind}.profraw" -o "$out/${kind}.profdata"
excl='(^|/)(test|build)/|/usr/'
llvm-cov report "$bin" -instr-profile="$out/${kind}.profdata" --ignore-filename-regex="$excl" | tee "$out/summary.txt"
llvm-cov export "$bin" -instr-profile="$out/${kind}.profdata" --ignore-filename-regex="$excl" -summary-only > "$out/summary.json"
llvm-cov show "$bin" -instr-profile="$out/${kind}.profdata" --ignore-filename-regex="$excl" \
  --format=html --show-mcdc -output-dir="$out/html"
llvm-cov show "$bin" -instr-profile="$out/${kind}.profdata" --ignore-filename-regex="$excl" \
  --show-mcdc > "$out/mcdc.txt"

case "$kind" in
  unit)        python3 .claude/skills/unit-test-skill/scripts/check_mcdc.py "$out/mcdc.txt" ;;
  integration) python3 scripts/ci/check_function_coverage.py "$out/summary.json" ;;
  *)           echo "[tdd] 별도 측정 완료 (게이트 없음)" ;;
esac
