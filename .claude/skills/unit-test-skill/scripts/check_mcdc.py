#!/usr/bin/env python3
"""llvm-cov --show-mcdc 출력에서 MC/DC 미충족 판정을 찾아 100% 여부를 검사한다.

@brief  mcdc.txt 를 파싱해 "Not Covered" 조건이 하나라도 있으면 exit 1.
@usage  check_mcdc.py <mcdc.txt>
@return 0: 모든 판정 MC/DC 충족, 1: 미충족 존재, 2: 입력 오류
"""
import re
import sys


def find_uncovered(lines):
    """@brief 미충족 조건 줄을 (줄번호, 내용) 목록으로 반환. @param lines 리포트 줄 목록."""
    pattern = re.compile(r"Condition C\d+.*(Not Covered)", re.IGNORECASE)
    return [(i + 1, ln.rstrip()) for i, ln in enumerate(lines) if pattern.search(ln)]


def count_decisions(lines):
    """@brief MC/DC 판정 수(MC/DC Decision Region 개수). @param lines 리포트 줄 목록."""
    return sum(1 for ln in lines if "MC/DC Decision Region" in ln)


def main(argv):
    """@brief 진입점. @param argv 명령행 인자. @return 종료 코드."""
    status = 0
    if len(argv) != 2:
        print(__doc__)
        status = 2
    else:
        with open(argv[1], encoding="utf-8", errors="replace") as fh:
            lines = fh.readlines()
        decisions = count_decisions(lines)
        missing = find_uncovered(lines)
        print(f"MC/DC decisions: {decisions}, uncovered conditions: {len(missing)}")
        for num, text in missing:
            print(f"  line {num}: {text}")
        if decisions == 0:
            print("경고: MC/DC 판정이 없습니다. -fcoverage-mcdc 빌드/clang 버전을 확인하세요.")
            status = 2
        elif missing:
            status = 1
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
