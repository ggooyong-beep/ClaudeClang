#!/usr/bin/env python3
"""llvm-cov export -summary-only JSON에서 함수 커버리지 100%를 검사한다.

@brief  함수 커버리지가 100% 미만이면 exit 1.
@usage  check_function_coverage.py <summary.json>
@return 0: 100%, 1: 미달, 2: 입력 오류
"""
import json
import sys


def main(argv):
    """@brief 진입점. @param argv 명령행 인자. @return 종료 코드."""
    status = 0
    if len(argv) != 2:
        print(__doc__)
        status = 2
    else:
        with open(argv[1], encoding="utf-8") as fh:
            totals = json.load(fh)["data"][0]["totals"]["functions"]
        print(f"function coverage: {totals['covered']}/{totals['count']} ({totals['percent']:.2f}%)")
        if totals["count"] == 0:
            print("측정 대상 함수가 없습니다.")
            status = 2
        elif totals["covered"] != totals["count"]:
            status = 1
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
