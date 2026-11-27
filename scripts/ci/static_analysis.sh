#!/usr/bin/env bash
# @brief CppCheck(예외 없음) + Lizard(CCN<=10, 함수 라인<=80) + CLOC. 컨테이너에서 실행.
set -uo pipefail
mkdir -p build/reports
dirs=()
for d in src include; do [ -n "$(find "$d" -name '*.[ch]*' 2>/dev/null | head -1)" ] && dirs+=("$d"); done
if [ ${#dirs[@]} -eq 0 ]; then
  echo "소스가 없어 정적분석을 건너뜀"
  echo '<?xml version="1.0"?><results version="2"><errors/></results>' > build/reports/cppcheck.xml
  : > build/reports/lizard.txt; : > build/reports/cloc.txt
  exit 0
fi
rc=0
# 전체 프로그램(src, include, test) 분석 — unusedFunction 은 전체 분석에서만 의미가 있다.
all_dirs=("${dirs[@]}"); [ -d test ] && all_dirs+=(test)
cppcheck --enable=all --inconclusive --library=googletest -I include   --xml --xml-version=2 "${all_dirs[@]}" 2> build/reports/cppcheck_all.xml
# 판정은 소스코드(src/, include/) 대상 지적 0건. 억제(suppress)는 사용하지 않는다.
python3 scripts/ci/filter_cppcheck.py build/reports/cppcheck_all.xml build/reports/cppcheck.xml || rc=1
lizard -C 10 -L 80 -w "${dirs[@]}" > build/reports/lizard.txt || rc=1
cloc "${dirs[@]}" --by-file > build/reports/cloc.txt
cat build/reports/lizard.txt
exit $rc
